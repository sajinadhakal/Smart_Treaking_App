from django.urls import re_path

from .consumers import DestinationChatConsumer

websocket_urlpatterns = [
    re_path(r'^ws/chat/destination/(?P<destination_id>\d+)/$', DestinationChatConsumer.as_asgi()),
]
