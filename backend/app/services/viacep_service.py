import httpx
import re
from typing import Optional
from app.models.cep import CEPResponse


class ViaCEPService:
    """Serviço para integração com a API do ViaCEP"""
    
    BASE_URL = "https://viacep.com.br/ws"
    
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=10.0)
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()
    
    def _clean_cep(self, cep: str) -> str:
        """Remove caracteres não numéricos do CEP"""
        return re.sub(r'\D', '', cep)
    
    def _validate_cep(self, cep: str) -> bool:
        """Valida se o CEP tem 8 dígitos"""
        clean_cep = self._clean_cep(cep)
        return len(clean_cep) == 8 and clean_cep.isdigit()
    
    async def get_address_by_cep(self, cep: str) -> Optional[CEPResponse]:
        """
        Busca endereço pelo CEP na API do ViaCEP
        
        Args:
            cep: CEP a ser consultado
            
        Returns:
            CEPResponse se encontrado, None se não encontrado
            
        Raises:
            ValueError: se o CEP for inválido
            httpx.HTTPError: se houver erro na requisição
        """
        if not self._validate_cep(cep):
            raise ValueError("CEP deve conter exatamente 8 dígitos numéricos")
        
        clean_cep = self._clean_cep(cep)
        url = f"{self.BASE_URL}/{clean_cep}/json/"
        
        try:
            response = await self.client.get(url)
            response.raise_for_status()
            
            data = response.json()
            
            # ViaCEP retorna {"erro": True} quando CEP não existe
            if data.get("erro"):
                return None
            
            # Formatar CEP para exibição
            formatted_cep = f"{clean_cep[:5]}-{clean_cep[5:]}"
            data["cep"] = formatted_cep
            
            return CEPResponse(**data)
            
        except httpx.HTTPError as e:
            raise httpx.HTTPError(f"Erro ao consultar ViaCEP: {str(e)}")
    
    async def close(self):
        """Fecha o cliente HTTP"""
        await self.client.aclose()
