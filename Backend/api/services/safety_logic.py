from typing import Dict, List


def analyze_trek_safety_and_finance(route_stops: List[Dict], nationality: str = 'Foreigner') -> Dict:
    """
    Core Logic: Acclimatization Safety and Cash Requirements.

    Rule:
    If altitude gain from stop A to stop B is >500m and stop B is above 3000m,
    mark itinerary as not safe and emit warning.
    """
    warnings: List[str] = []
    is_safe = True

    for index in range(1, len(route_stops)):
        prev_alt = int(route_stops[index - 1].get('altitude', 0))
        curr_alt = int(route_stops[index].get('altitude', 0))
        stop_name = route_stops[index].get('name', f'Stop {index + 1}')
        altitude_gain = curr_alt - prev_alt

        if curr_alt > 3000 and altitude_gain > 500:
            is_safe = False
            warnings.append(
                f"Safety Alert: Elevation gain to {stop_name} is {altitude_gain}m. "
                "Above 3000m, keep gain under 500m to prevent AMS."
            )

    daily_expense_npr = 4500
    duration_days = max(len(route_stops), 1)
    permit_fee_npr = 5000 if nationality == 'Foreigner' else 2000

    total_cash_required = (duration_days * daily_expense_npr) + permit_fee_npr
    total_cash_required *= 1.20

    return {
        'is_safe': is_safe,
        'safety_warnings': warnings,
        'cash_required_npr': round(total_cash_required, 0),
        'cash_required_usd': round(total_cash_required / 132, 2),
    }
