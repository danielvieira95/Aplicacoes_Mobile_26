from rest_framework import viewsets
from .models import Produto
from .serializers import ProdutoSerializer

# Create your views here

class ProdutoViewSet(viewsets.ModelViewSet):
    queryset = Produto.objects.all().order_by("-id")
    serializer_class = ProdutoSerializer
