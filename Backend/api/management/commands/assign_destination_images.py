from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import quote

import requests
from django.conf import settings
from django.core.management.base import BaseCommand
from django.utils.text import slugify

from api.models import Destination


class Command(BaseCommand):
    help = "Fetch and assign individual images for destinations using Wikipedia summaries."

    WIKIPEDIA_SUMMARY_URL = "https://en.wikipedia.org/api/rest_v1/page/summary/{title}"
    REQUEST_HEADERS = {
        "User-Agent": "NepalTrekkingApp/1.0 (educational project; contact: local@localhost)",
        "Accept": "application/json",
    }

    TITLE_HINTS = {
        "Ama Dablam Base Camp Trek": ["Ama Dablam", "Ama Dablam Base Camp"],
        "Annapurna Base Camp Trek": ["Annapurna Base Camp", "Annapurna Sanctuary"],
        "Annapurna Circuit Trek": ["Annapurna Circuit"],
        "Annapurna Circuit with Tilicho Lake Trek": ["Tilicho Lake", "Annapurna Circuit"],
        "Annapurna Sanctuary Trek": ["Annapurna Sanctuary"],
        "Budget Everest Base Camp Trek": ["Everest Base Camp"],
        "Dhaulagiri Circuit Trek": ["Dhaulagiri"],
        "Everest Base Camp": ["Everest Base Camp"],
        "Everest Base Camp with Gokyo Lakes Trek": ["Gokyo Lakes", "Everest Base Camp"],
        "Everest Panorama Trek": ["Everest", "Namche Bazaar"],
        "Everest Three Passes Trek": ["Everest Three Passes", "Khumbu"],
        "Ghorepani Poon Hill Trek": ["Poon Hill", "Ghorepani"],
        "Gokyo Lakes Trek": ["Gokyo Lakes"],
        "Helambu Trek": ["Helambu"],
        "Jiri to Everest Base Camp Trek": ["Jiri", "Everest Base Camp"],
        "Kanchenjunga Base Camp Trek": ["Kanchenjunga"],
        "Kanchenjunga South Base Camp Trek": ["Kanchenjunga"],
        "Khopra Danda Trek": ["Khopra Danda", "Annapurna"],
        "Langtang Gosaikunda Trek": ["Gosaikunda", "Langtang"],
        "Langtang Valley Trek": ["Langtang Valley", "Langtang National Park"],
        "Luxury Everest Base Camp Trek": ["Everest Base Camp"],
        "Makalu Base Camp Trek": ["Makalu"],
        "Manaslu Circuit Trek": ["Manaslu Circuit"],
        "Mardi Himal Trek": ["Mardi Himal"],
        "Nar Phu Valley Trek": ["Nar Phu", "Annapurna"],
        "Pikey Peak Trek": ["Pikey Peak"],
        "Rara Lake Trek": ["Rara Lake"],
        "Ruby Valley Trek": ["Ruby Valley", "Ganesh Himal"],
        "Semi-Luxury Everest Base Camp Trek": ["Everest Base Camp"],
        "Tamang Heritage Trail": ["Tamang Heritage Trail", "Langtang National Park"],
        "Tsum Valley Trek": ["Tsum Valley", "Manaslu"],
        "Upper Dolpo Trek": ["Dolpo"],
        "Upper Mustang Trek": ["Upper Mustang"],
    }

    def add_arguments(self, parser):
        parser.add_argument(
            "--overwrite",
            action="store_true",
            help="Overwrite existing image values (recommended when replacing placeholders).",
        )

    def _candidate_titles(self, destination_name: str) -> list[str]:
        candidates: list[str] = []

        if destination_name in self.TITLE_HINTS:
            candidates.extend(self.TITLE_HINTS[destination_name])

        cleaned = destination_name.replace(" Trek", "").replace(" with ", " ")
        candidates.extend([destination_name, cleaned])

        # Preserve order while removing duplicates.
        seen = set()
        unique_candidates = []
        for title in candidates:
            normalized = title.strip()
            if not normalized or normalized in seen:
                continue
            seen.add(normalized)
            unique_candidates.append(normalized)
        return unique_candidates

    def _fetch_wikipedia_image_url(self, title: str) -> str | None:
        url = self.WIKIPEDIA_SUMMARY_URL.format(title=quote(title, safe=""))
        response = requests.get(url, headers=self.REQUEST_HEADERS, timeout=12)
        if response.status_code != 200:
            return None

        data = response.json()
        thumb = data.get("thumbnail", {})
        original = data.get("originalimage", {})
        return thumb.get("source") or original.get("source")

    def _download_image(self, image_url: str, file_path: Path) -> bool:
        response = requests.get(image_url, headers=self.REQUEST_HEADERS, timeout=20)
        if response.status_code != 200 or not response.content:
            return False

        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_bytes(response.content)
        return True

    def handle(self, *args, **options):
        overwrite = options.get("overwrite", False)
        media_root = Path(settings.MEDIA_ROOT)
        destinations_dir = media_root / "destinations"
        destinations_dir.mkdir(parents=True, exist_ok=True)

        total = 0
        updated = 0
        skipped = 0
        failed = 0

        queryset = Destination.objects.order_by("name")

        for destination in queryset:
            total += 1
            existing_name = (destination.image.name or "").strip() if destination.image else ""
            is_placeholder = existing_name.endswith("destinations/OIP.webp")

            if existing_name and not overwrite and not is_placeholder:
                skipped += 1
                self.stdout.write(f"SKIP existing image: {destination.name}")
                continue

            image_url = None
            for title in self._candidate_titles(destination.name):
                try:
                    image_url = self._fetch_wikipedia_image_url(title)
                except Exception:
                    image_url = None
                if image_url:
                    break

            if not image_url:
                failed += 1
                self.stdout.write(self.style.WARNING(f"NO IMAGE SOURCE: {destination.name}"))
                continue

            extension = os.path.splitext(image_url.split("?")[0])[1].lower()
            if extension not in {".jpg", ".jpeg", ".png", ".webp"}:
                extension = ".jpg"

            file_name = f"{slugify(destination.name)}{extension}"
            absolute_file = destinations_dir / file_name
            relative_name = f"destinations/{file_name}"

            try:
                if not self._download_image(image_url, absolute_file):
                    failed += 1
                    self.stdout.write(self.style.WARNING(f"DOWNLOAD FAILED: {destination.name}"))
                    continue
            except Exception as exc:
                failed += 1
                self.stdout.write(self.style.WARNING(f"ERROR {destination.name}: {exc}"))
                continue

            destination.image.name = relative_name
            destination.save(update_fields=["image", "updated_at"])
            updated += 1
            self.stdout.write(self.style.SUCCESS(f"UPDATED {destination.name} -> {relative_name}"))

        self.stdout.write("\nImage assignment complete")
        self.stdout.write(f"Total: {total}")
        self.stdout.write(f"Updated: {updated}")
        self.stdout.write(f"Skipped: {skipped}")
        self.stdout.write(f"Failed: {failed}")
