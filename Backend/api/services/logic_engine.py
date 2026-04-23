from decimal import Decimal
from typing import Dict, List, Optional

from api.models import Guide

USD_TO_NPR = Decimal('132.0')


def acclimatization_guard(route_stops: List[Dict]) -> Dict:
    warnings: List[str] = []
    is_safe = True

    for index in range(1, len(route_stops)):
        prev_alt = int(route_stops[index - 1].get('altitude', 0))
        curr_alt = int(route_stops[index].get('altitude', 0))
        stop_name = route_stops[index].get('name', f'Stop {index + 1}')
        gain = curr_alt - prev_alt

        if curr_alt > 3000 and gain > 500:
            is_safe = False
            warnings.append(
                f'Safety Alert: Elevation gain to {stop_name} is {gain}m. Above 3000m, keep gain under 500m to prevent AMS.'
            )

    return {
        'is_safe': is_safe,
        'safety_warnings': warnings,
    }


def cash_calculator(duration_days: int, nationality: str, guide_fee_npr: float = 0) -> Dict:
    daily_expense_npr = Decimal('4500')
    permit_fee_npr = Decimal('5000') if nationality == 'Foreigner' else Decimal('2000')

    total_cash = (Decimal(max(duration_days, 1)) * daily_expense_npr) + permit_fee_npr + Decimal(str(guide_fee_npr))
    total_cash *= Decimal('1.20')

    return {
        'cash_required_npr': float(total_cash.quantize(Decimal('1'))),
        'cash_required_usd': float((total_cash / USD_TO_NPR).quantize(Decimal('0.01'))),
    }


def guide_matcher(is_restricted_area: bool, selected_guide: Optional[Guide]) -> Dict:
    matched = selected_guide is not None and bool(selected_guide.is_active)
    is_compliant = (not is_restricted_area) or matched

    return {
        'guide_required': is_restricted_area,
        'guide_matched': matched,
        'is_legal_compliant': is_compliant,
    }


def analyze_trek(route_stops: List[Dict], nationality: str, is_restricted_area: bool, selected_guide: Optional[Guide]) -> Dict:
    safety = acclimatization_guard(route_stops)

    guide_daily_npr = 0.0
    if selected_guide:
        guide_daily_npr = float(Decimal(str(selected_guide.daily_rate)) * USD_TO_NPR)

    finance = cash_calculator(
        duration_days=len(route_stops),
        nationality=nationality,
        guide_fee_npr=guide_daily_npr * max(len(route_stops), 1),
    )
    compliance = guide_matcher(is_restricted_area=is_restricted_area, selected_guide=selected_guide)

    algorithm_steps = [
        'Acclimatization Guard executed over route nodes (O(n)).',
        'Cash calculator applied daily + permit + guide + 20% emergency buffer.',
        'Guide matcher validated restricted-area legal compliance.',
    ]

    return {
        **safety,
        **finance,
        **compliance,
        'algorithm_steps': algorithm_steps,
    }
