from rest_framework import serializers

class ImageSerializer(serializers.Serializer):
    file = serializers.ImageField()