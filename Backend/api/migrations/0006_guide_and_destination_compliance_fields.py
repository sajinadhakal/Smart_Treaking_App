from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0005_costconfiguration_detour_trekactivity_trekitinerary_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='destination',
            name='base_price_npr',
            field=models.FloatField(default=0, help_text='Base package price in NPR'),
        ),
        migrations.AddField(
            model_name='destination',
            name='difficulty_level',
            field=models.CharField(choices=[('EASY', 'Easy'), ('MODERATE', 'Moderate'), ('CHALLENGING', 'Challenging'), ('DIFFICULT', 'Difficult')], default='MODERATE', max_length=20),
        ),
        migrations.AddField(
            model_name='destination',
            name='is_restricted_area',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='destination',
            name='max_altitude',
            field=models.IntegerField(default=0, help_text='Maximum altitude in meters'),
        ),
        migrations.AlterField(
            model_name='userprofile',
            name='nationality',
            field=models.CharField(choices=[('NEPALI', 'Nepali'), ('INTERNATIONAL', 'International')], default='INTERNATIONAL', help_text='Used for dynamic cost estimation', max_length=20),
        ),
        migrations.CreateModel(
            name='Guide',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=150)),
                ('license_number', models.CharField(max_length=100, unique=True)),
                ('experience_years', models.IntegerField(default=1)),
                ('specialization', models.CharField(blank=True, max_length=150)),
                ('daily_rate', models.DecimalField(decimal_places=2, default=35.0, max_digits=10)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'ordering': ['name'],
            },
        ),
        migrations.AddField(
            model_name='trekitinerary',
            name='calculated_safety_json',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='trekitinerary',
            name='selected_guide',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='itineraries', to='api.guide'),
        ),
    ]
