from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0007_review_image'),
    ]

    operations = [
        migrations.AddField(
            model_name='costconfiguration',
            name='bus_transport_cost',
            field=models.DecimalField(decimal_places=2, default=5.0, help_text='Round-trip bus/jeep to trailhead per person (USD)', max_digits=8),
        ),
        migrations.AddField(
            model_name='costconfiguration',
            name='hotel_cost_per_night',
            field=models.DecimalField(decimal_places=2, default=20.0, help_text='Hotel/lodge cost per night per person (USD)', max_digits=8),
        ),
        migrations.AddField(
            model_name='costconfiguration',
            name='meals_cost_per_day',
            field=models.DecimalField(decimal_places=2, default=10.0, help_text='Meals & snacks per day per person (USD)', max_digits=8),
        ),
    ]
