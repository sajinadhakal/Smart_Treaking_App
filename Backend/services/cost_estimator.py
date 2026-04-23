"""
Dynamic Cost Estimator Service
Calculates trek costs based on:
- User nationality (Nepali vs International)
- Trip duration
- Guide/Porter hiring
- Selected detours
- Permit fees
"""

from decimal import Decimal
from typing import Dict, List, Tuple, Optional
from api.models import CostConfiguration, Detour, Destination, Guide


class CostEstimator:
    """
    Calculates trek costs with nationality-based pricing and service options.
    
    Cost Breakdown:
    1. Base Cost = destination.price * nationality_multiplier
    2. Permit Cost = permit_fee_per_person * number_of_people
    3. Guide Cost = guide_daily_rate * days * (1 if include_guide else 0)
    4. Porter Cost = porter_daily_rate * days * number_of_porters * (1 if include_porter else 0)
    5. Detour Cost = sum(detour.extra_cost for each selected detour)
    6. Total = Base + Permit + Guide + Porter + Detour
    """

    USD_TO_NPR = Decimal('133')
    MAX_PER_PERSON_BUDGET_NPR = Decimal('20000')
    
    def estimate_cost(self,
                      destination: Destination,
                      duration_days: int,
                      number_of_people: int,
                      nationality: str = 'INTERNATIONAL',
                      include_guide: bool = False,
                      selected_guide: Optional[Guide] = None,
                      include_porter: bool = False,
                      number_of_porters: int = 1,
                      selected_detour_ids: List[int] = None) -> Dict:
        """
        Calculate total cost for a trek with given parameters.
        
        Args:
            destination: Destination object
            duration_days: Number of days for the trek
            number_of_people: Number of people in the group
            nationality: 'NEPALI' or 'INTERNATIONAL'
            include_guide: Whether to hire a guide
            include_porter: Whether to hire porters
            number_of_porters: How many porters (if include_porter=True)
            selected_detour_ids: List of detour IDs to include
        
        Returns:
            {
                base_cost: Decimal,
                permit_cost: Decimal,
                guide_cost: Decimal,
                porter_cost: Decimal,
                detour_cost: Decimal,
                total_cost: Decimal,
                cost_breakdown: Dict for visualization,
                execution_steps: List[str]
            }
        """
        execution_steps = []
        
        try:
            cost_config = destination.cost_config
        except CostConfiguration.DoesNotExist:
            # Create default config if not exists
            cost_config = CostConfiguration.objects.create(destination=destination)
        
        execution_steps.append(f"Cost Estimator: {destination.name} for {number_of_people} people, {duration_days} days")
        normalized_nationality = 'NEPALI' if nationality in ['NEPALI', 'SAARC'] else 'INTERNATIONAL'
        execution_steps.append(
            f"Nationality: {normalized_nationality}, Guide: {include_guide}, Porters: {number_of_porters if include_porter else 0}"
        )
        
        # ===== 1. Actual Daily Costs ========
        # Hotel/Lodging
        hotel_cost_per_person = Decimal(str(cost_config.hotel_cost_per_night)) * Decimal(duration_days)
        hotel_cost = hotel_cost_per_person * number_of_people
        execution_steps.append(f"Hotel: ${cost_config.hotel_cost_per_night:.2f}/night × {duration_days} nights × {number_of_people} people = ${hotel_cost:.2f}")
        
        # Meals & Food
        meals_cost_per_person = Decimal(str(cost_config.meals_cost_per_day)) * Decimal(duration_days)
        meals_cost = meals_cost_per_person * number_of_people
        execution_steps.append(f"Meals: ${cost_config.meals_cost_per_day:.2f}/day × {duration_days} days × {number_of_people} people = ${meals_cost:.2f}")
        
        # Bus/Transport to trailhead
        transport_cost_per_person = Decimal(str(cost_config.bus_transport_cost))
        transport_cost = transport_cost_per_person * number_of_people
        execution_steps.append(f"Bus/Transport: ${cost_config.bus_transport_cost:.2f} per person × {number_of_people} = ${transport_cost:.2f}")
        
        # No separate trek-entry fee is added to avoid double counting.
        # Core trek cost is hotel + meals + transport.
        if normalized_nationality == 'NEPALI':
            multiplier = cost_config.saarc_discount_multiplier
            execution_steps.append(f"Nepali/SAARC multiplier: {multiplier}")
        else:
            multiplier = cost_config.international_multiplier
            execution_steps.append(f"International multiplier: {multiplier}")

        base_cost = hotel_cost + meals_cost + transport_cost
        execution_steps.append(f"Core Trek Cost (Hotel+Food+Bus): ${base_cost:.2f}")
        
        # ===== 2. Permit Cost ========
        if normalized_nationality == 'NEPALI':
            permit_per_person = cost_config.permit_fee_saarc
        else:
            permit_per_person = cost_config.permit_fee_international
        
        permit_cost = permit_per_person * number_of_people
        execution_steps.append(f"Permit cost: ${permit_per_person:.2f} per person × {number_of_people} = ${permit_cost:.2f}")
        
        # ===== 3. Guide Cost ========
        guide_cost = Decimal(0)
        if include_guide:
            guide_daily_rate = Decimal(str(selected_guide.daily_rate)) if selected_guide else Decimal(str(cost_config.guide_daily_rate))
            guide_cost = guide_daily_rate * Decimal(duration_days)
            if selected_guide:
                execution_steps.append(f"Guide: ${guide_daily_rate:.2f}/day ({selected_guide.name}) × {duration_days} days = ${guide_cost:.2f}")
            else:
                execution_steps.append(f"Guide: ${guide_daily_rate:.2f}/day × {duration_days} days = ${guide_cost:.2f}")
        else:
            execution_steps.append("Guide: Not included")
        
        # ===== 4. Porter Cost ========
        porter_cost = Decimal(0)
        if include_porter and number_of_porters > 0:
            porter_cost = (Decimal(str(cost_config.porter_daily_rate)) * 
                          Decimal(duration_days) * 
                          Decimal(number_of_porters))
            execution_steps.append(f"Porters: ${cost_config.porter_daily_rate:.2f}/day × {duration_days} days × {number_of_porters} porters = ${porter_cost:.2f}")
        else:
            execution_steps.append("Porters: Not included")
        
        # ===== 5. Detour Cost ========
        detour_cost = Decimal(0)
        selected_detours = []
        
        if selected_detour_ids:
            selected_detours = Detour.objects.filter(id__in=selected_detour_ids)
            detour_cost = sum(Decimal(str(d.extra_cost_usd)) for d in selected_detours)
            
            execution_steps.append(f"\n--- OPTIONAL DETOURS ({len(selected_detours)}) ---")
            for detour in selected_detours:
                execution_steps.append(f"  • {detour.name}: ${detour.extra_cost_usd:.2f} (+{detour.extra_days} days)")
            
            execution_steps.append(f"Total detour cost: ${detour_cost:.2f}")
        else:
            execution_steps.append("Detours: None selected")
        
        # ===== 6. Total Cost ========
        total_cost = base_cost + permit_cost + guide_cost + porter_cost + detour_cost
        
        execution_steps.append(f"\n{'='*40}")
        execution_steps.append(f"{'DETAILED COST BREAKDOWN':^40}")
        execution_steps.append(f"{'='*40}")
        execution_steps.append(f"Hotel/Lodging       ${hotel_cost:>10.2f}")
        execution_steps.append(f"Meals & Food        ${meals_cost:>10.2f}")
        execution_steps.append(f"Bus/Transport       ${transport_cost:>10.2f}")
        execution_steps.append(f"Permits             ${permit_cost:>10.2f}")
        if guide_cost > 0:
            execution_steps.append(f"Guide Services      ${guide_cost:>10.2f}")
        if porter_cost > 0:
            execution_steps.append(f"Porter Services     ${porter_cost:>10.2f}")
        if detour_cost > 0:
            execution_steps.append(f"Optional Detours    ${detour_cost:>10.2f}")
        execution_steps.append(f"{'-'*40}")
        execution_steps.append(f"TOTAL (All)         ${total_cost:>10.2f}")
        
        # Enforce per-person budget cap (Rs 20,000) by proportional scaling.
        cost_per_person = total_cost / number_of_people
        per_person_npr = cost_per_person * self.USD_TO_NPR
        if per_person_npr > self.MAX_PER_PERSON_BUDGET_NPR:
            scale = self.MAX_PER_PERSON_BUDGET_NPR / per_person_npr

            hotel_cost *= scale
            meals_cost *= scale
            transport_cost *= scale
            permit_cost *= scale
            guide_cost *= scale
            porter_cost *= scale
            detour_cost *= scale

            base_cost = hotel_cost + meals_cost + transport_cost
            total_cost = base_cost + permit_cost + guide_cost + porter_cost + detour_cost
            cost_per_person = total_cost / number_of_people

            execution_steps.append(
                f"Budget cap applied: per person limited to Rs {self.MAX_PER_PERSON_BUDGET_NPR:.0f}."
            )

        execution_steps.append(f"Per Person          ${cost_per_person:>10.2f}")
        if duration_days > 1:
            execution_steps.append(f"Per Person/Day      ${cost_per_person / duration_days:>10.2f}")
        
        
        cost_breakdown = {
            'hotel': float(hotel_cost),
            'meals': float(meals_cost),
            'transport': float(transport_cost),
            'base': float(base_cost),
            'permit': float(permit_cost),
            'guide': float(guide_cost),
            'porter': float(porter_cost),
            'detour': float(detour_cost),
        }
        
        # Detailed analytics for frontend (actual costs, not percentages)
        detailed_expenses = {
            'lodging': float(hotel_cost),
            'meals': float(meals_cost),
            'local_transport': float(transport_cost),
            'trek_entry_fee': 0.0,
            'permits': float(permit_cost),
            'guide': float(guide_cost),
            'porter': float(porter_cost),
            'detours': float(detour_cost),
        }
        
        # Per-person breakdown
        per_person_expenses = {
            'lodging': float(hotel_cost / number_of_people),
            'meals': float(meals_cost / number_of_people),
            'local_transport': float(transport_cost / number_of_people),
            'trek_entry_fee': 0.0,
            'permits': float(permit_cost / number_of_people),
            'guide': float(guide_cost / number_of_people) if guide_cost > 0 else 0.0,
            'porter': float(porter_cost / number_of_people) if porter_cost > 0 else 0.0,
            'detours': float(detour_cost / number_of_people) if detour_cost > 0 else 0.0,
        }
        
        
        return {
            'base_cost': base_cost,
            'permit_cost': permit_cost,
            'guide_cost': guide_cost,
            'porter_cost': porter_cost,
            'detour_cost': detour_cost,
            'total_cost': total_cost,
            'cost_per_person': cost_per_person,
            'cost_breakdown': cost_breakdown,
            'detailed_expenses': detailed_expenses,
            'per_person_expenses': per_person_expenses,
            'selected_detours': list(selected_detours),
            'total_duration_days': duration_days + sum(d.extra_days for d in selected_detours),
            'duration_days': duration_days,
            'number_of_people': number_of_people,
            'execution_steps': execution_steps
        }
    
    def estimate_cost_range(self, destination: Destination) -> Dict:
        """
        Calculate min/max cost range for a destination.
        Min: solo Nepali traveler, no guide/porter, no detours
        Max: group of 4 international travelers, guide, porters, all detours
        
        Returns:
            {
                min_cost: Decimal,
                max_cost: Decimal,
                min_config: Dict,
                max_config: Dict
            }
        """
        try:
            cost_config = destination.cost_config
        except CostConfiguration.DoesNotExist:
            cost_config = CostConfiguration.objects.create(destination=destination)
        
        # Minimum cost
        min_result = self.estimate_cost(
            destination=destination,
            duration_days=destination.duration_days,
            number_of_people=1,
            nationality='NEPALI',
            include_guide=False,
            include_porter=False,
            selected_detour_ids=[]
        )
        
        # Maximum cost
        all_detours = Detour.objects.filter(destination=destination).values_list('id', flat=True)
        max_result = self.estimate_cost(
            destination=destination,
            duration_days=destination.duration_days,
            number_of_people=4,
            nationality='INTERNATIONAL',
            include_guide=True,
            include_porter=True,
            number_of_porters=2,
            selected_detour_ids=list(all_detours)
        )
        
        return {
            'min_cost': min_result['total_cost'],
            'max_cost': max_result['total_cost'],
            'min_config': {
                'people': 1,
                'nationality': 'NEPALI',
                'guide': False,
                'porters': 0
            },
            'max_config': {
                'people': 4,
                'nationality': 'INTERNATIONAL',
                'guide': True,
                'porters': 2
            }
        }
