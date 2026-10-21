from django.contrib import admin
from .models import Produto

# Register your models here.
@admin.register(Produto)
class ProdutoAdmin(admin.ModelAdmin):
    list_display = ("id","nome","quantidade","preco","created_at")
    search_fields = ("nome",)
