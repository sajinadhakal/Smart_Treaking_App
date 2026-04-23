from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0006_guide_and_destination_compliance_fields'),
    ]

    operations = [
        migrations.AddField(
            model_name='review',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to='reviews/'),
        ),
    ]
