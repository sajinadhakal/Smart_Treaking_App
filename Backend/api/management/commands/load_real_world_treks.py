from django.core.management.base import BaseCommand

from api.models import Destination, TrekRoute, Guide


class Command(BaseCommand):
    help = 'Load 7 real-world Nepal treks with 2026 altitude and pricing data.'

    def handle(self, *args, **options):
        self.stdout.write('Loading real-world trek destinations...')

        treks = [
            {
                'name': 'Everest Base Camp',
                'description': 'Classic Khumbu route to Everest Base Camp with iconic Sherpa settlements.',
                'location': 'Khumbu Region, Nepal',
                'altitude': 5364,
                'duration_days': 12,
                'difficulty': 'CHALLENGING',
                'price': 1250.00,
                'base_price_npr': 165000,
                'is_restricted_area': False,
                'featured': True,
                'best_season': 'Oct-Nov',
                'group_size_max': 12,
                'latitude': 27.9881,
                'longitude': 86.9250,
                'route_points': [
                    ('Lukla', 2860),
                    ('Namche Bazaar', 3440),
                    ('Dingboche', 4410),
                    ('Lobuche', 4940),
                    ('Everest Base Camp', 5364),
                ],
            },
            {
                'name': 'Annapurna Circuit',
                'description': 'Long trans-Himalayan circuit crossing Thorong La with diverse terrain.',
                'location': 'Annapurna Region, Nepal',
                'altitude': 5416,
                'duration_days': 14,
                'difficulty': 'DIFFICULT',
                'price': 910.00,
                'base_price_npr': 120000,
                'is_restricted_area': False,
                'featured': True,
                'best_season': 'Mar-May',
                'group_size_max': 14,
                'latitude': 28.5961,
                'longitude': 83.8203,
                'route_points': [
                    ('Besisahar', 760),
                    ('Chame', 2670),
                    ('Manang', 3519),
                    ('Thorong Phedi', 4450),
                    ('Thorong La Pass', 5416),
                ],
            },
            {
                'name': 'Langtang Valley',
                'description': 'Scenic and culturally rich trek north of Kathmandu through Tamang villages.',
                'location': 'Langtang Region, Nepal',
                'altitude': 3870,
                'duration_days': 8,
                'difficulty': 'MODERATE',
                'price': 492.00,
                'base_price_npr': 65000,
                'is_restricted_area': False,
                'featured': True,
                'best_season': 'Oct-Nov',
                'group_size_max': 14,
                'latitude': 28.2118,
                'longitude': 85.5560,
                'route_points': [
                    ('Syabrubesi', 1550),
                    ('Lama Hotel', 2470),
                    ('Langtang Village', 3430),
                    ('Kyanjin Gompa', 3870),
                ],
            },
            {
                'name': 'Manaslu Circuit',
                'description': 'Remote high-altitude circuit with rich mountain culture and wild landscapes.',
                'location': 'Manaslu Region, Nepal',
                'altitude': 5160,
                'duration_days': 14,
                'difficulty': 'DIFFICULT',
                'price': 1061.00,
                'base_price_npr': 140000,
                'is_restricted_area': True,
                'featured': True,
                'best_season': 'Sep-Nov',
                'group_size_max': 10,
                'latitude': 28.5490,
                'longitude': 84.5617,
                'route_points': [
                    ('Soti Khola', 710),
                    ('Namrung', 2630),
                    ('Samagaun', 3530),
                    ('Samdo', 3875),
                    ('Larkya La Pass', 5160),
                ],
            },
            {
                'name': 'Gokyo Lakes',
                'description': 'Everest-region alternative with turquoise high-altitude lakes and Renjo views.',
                'location': 'Khumbu Region, Nepal',
                'altitude': 5357,
                'duration_days': 11,
                'difficulty': 'CHALLENGING',
                'price': 985.00,
                'base_price_npr': 130000,
                'is_restricted_area': False,
                'featured': True,
                'best_season': 'Mar-May',
                'group_size_max': 12,
                'latitude': 27.9572,
                'longitude': 86.6913,
                'route_points': [
                    ('Lukla', 2860),
                    ('Namche Bazaar', 3440),
                    ('Dole', 4038),
                    ('Machhermo', 4470),
                    ('Gokyo Lakes', 5357),
                ],
            },
            {
                'name': 'Upper Mustang',
                'description': 'Arid trans-Himalayan trekking route into the ancient kingdom of Lo.',
                'location': 'Mustang Region, Nepal',
                'altitude': 4200,
                'duration_days': 12,
                'difficulty': 'MODERATE',
                'price': 1894.00,
                'base_price_npr': 250000,
                'is_restricted_area': True,
                'featured': True,
                'best_season': 'Mar-Nov',
                'group_size_max': 10,
                'latitude': 29.1800,
                'longitude': 83.9500,
                'route_points': [
                    ('Jomsom', 2743),
                    ('Kagbeni', 2810),
                    ('Chele', 3050),
                    ('Ghami', 3520),
                    ('Lo Manthang', 3840),
                    ('High Point', 4200),
                ],
            },
            {
                'name': 'Mardi Himal',
                'description': 'Short and scenic ridge trek with panoramic Annapurna and Machapuchare views.',
                'location': 'Annapurna Region, Nepal',
                'altitude': 4500,
                'duration_days': 6,
                'difficulty': 'MODERATE',
                'price': 341.00,
                'base_price_npr': 45000,
                'is_restricted_area': False,
                'featured': False,
                'best_season': 'Mar-May',
                'group_size_max': 14,
                'latitude': 28.4459,
                'longitude': 83.8222,
                'route_points': [
                    ('Kande', 1770),
                    ('Forest Camp', 2520),
                    ('Low Camp', 2970),
                    ('High Camp', 3550),
                    ('Mardi Himal Base Camp', 4500),
                ],
            },
        ]

        for trek in treks:
            destination, _ = Destination.objects.update_or_create(
                name=trek['name'],
                defaults={
                    'description': trek['description'],
                    'location': trek['location'],
                    'altitude': trek['altitude'],
                    'max_altitude': trek['altitude'],
                    'duration_days': trek['duration_days'],
                    'difficulty': trek['difficulty'],
                    'difficulty_level': trek['difficulty'],
                    'price': trek['price'],
                    'base_price_npr': trek['base_price_npr'],
                    'is_restricted_area': trek['is_restricted_area'],
                    'featured': trek['featured'],
                    'best_season': trek['best_season'],
                    'group_size_max': trek['group_size_max'],
                    'latitude': trek['latitude'],
                    'longitude': trek['longitude'],
                },
            )

            TrekRoute.objects.filter(destination=destination).delete()
            for index, (name, altitude) in enumerate(trek['route_points'], start=1):
                TrekRoute.objects.create(
                    destination=destination,
                    sequence_order=index,
                    latitude=destination.latitude,
                    longitude=destination.longitude,
                    altitude=altitude,
                    location_name=name,
                    description=f'Day {index} stop for {destination.name}',
                )

        Guide.objects.update_or_create(
            license_number='NTB-G-1021',
            defaults={
                'name': 'Nima Sherpa',
                'experience_years': 12,
                'specialization': 'Everest / High Altitude',
                'daily_rate': 45.0,
                'is_active': True,
            },
        )
        Guide.objects.update_or_create(
            license_number='NTB-G-1178',
            defaults={
                'name': 'Pema Gurung',
                'experience_years': 9,
                'specialization': 'Annapurna / Circuit Treks',
                'daily_rate': 38.0,
                'is_active': True,
            },
        )
        Guide.objects.update_or_create(
            license_number='NTB-G-1256',
            defaults={
                'name': 'Dorje Tamang',
                'experience_years': 7,
                'specialization': 'Restricted Area Logistics',
                'daily_rate': 42.0,
                'is_active': True,
            },
        )

        self.stdout.write(self.style.SUCCESS('Loaded 7 real-world trek destinations and guide profiles successfully.'))
