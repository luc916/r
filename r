import requests

class Pacote:
    def __init__(self, dimensoes, peso):
        self.dimensoes = dimensoes.split(',')
        self.peso = float(peso)
        self.volume = self.calcular_dados()

    def calcular_dados(self):
        # Lógica para calcular o volume
        if len(self.dimensoes) == 3:
            largura = float(self.dimensoes[0])
            altura = float(self.dimensoes[1])
            profundidade = float(self.dimensoes[2])
            volume = largura * altura * profundidade
        elif len(self.dimensoes) == 1:
            # Se apenas um valor for fornecido, ele é tratado como o volume final
            volume = float(self.dimensoes[0])
        else:
            volume = None
        return volume

    def verificar_transporte(self):
        # Densidade média: 1 kg ≈ 1000 cm³
        densidade_media = 1  # kg/dm³ (1 dm³ = 1000 cm³)
        peso_equivalente_volume = (self.volume / 1000) * densidade_media if self.volume else None

        # Simulação de seleção de transporte baseado em regras logísticas
        if self.peso > 50 or (peso_equivalente_volume and peso_equivalente_volume > 50):
            return 'Transporte rodoviário pesado (Caminhão especial)'
        elif self.volume > 10000 or self.peso > 10:
            return 'Transporte rodoviário padrão, com entrega nos finais de semana'
        elif self.volume <= 10000 and self.peso <= 10:
            return 'Transporte aéreo (entrega rápida)'
        else:
            return 'Dados inválidos ou transporte não especificado.'

    def calcular_frete(self, distancia):
        # Cálculo do frete com base na distância e tipo de transporte
        if self.volume and self.peso:
            custo_por_km_rodoviario = 1.50  # Exemplo: R$ 1,50 por km para rodoviário
            custo_por_km_aereo = 3.00  # Exemplo: R$ 3,00 por km para aéreo

            tipo_transporte = self.verificar_transporte()
            if tipo_transporte == 'Transporte rodoviário pesado (Caminhão especial)' or tipo_transporte == 'Transporte rodoviário padrão, com entrega nos finais de semana':
                frete = distancia * custo_por_km_rodoviario
            elif tipo_transporte == 'Transporte aéreo (entrega rápida)':
                frete = distancia * custo_por_km_aereo
            else:
                frete = None
            return frete
        else:
            return None

    def estimar_dias_entrega(self, distancia):
        # Estimativa de dias úteis para entrega com base na distância
        if distancia <= 50:  # Localidades próximas
            return 1
        elif distancia <= 300:  # Dentro do estado ou regiões próximas
            return 3
        elif distancia <= 1500:  # Regiões mais distantes
            return 5
        else:  # Envio para regiões muito distantes
            return 7

# Função para consulta de CEP utilizando ViaCEP
def consultar_cep(cep):
    url = f"https://viacep.com.br/ws/{cep}/json/"
    try:
        response = requests.get(url)
        response.raise_for_status()
        dados = response.json()
        if "erro" not in dados:
            return dados.get("localidade"), dados.get("uf")  # Retorna cidade e estado
        else:
            print("CEP inválido ou não encontrado.")
            return None, None
    except requests.exceptions.RequestException as e:
        print(f"Erro na consulta do CEP: {e}")
        return None, None

# Função para entrada de pacotes manualmente
def entrada_pacotes():
    print("Bem-vindo à Simulação Logística!")
    print("Insira o CEP apenas uma vez para calcular a distância.")
    print("Após inserir todos os pacotes, pressione ENTER sem inserir dimensões para encerrar.")

    cep = input("\nInsira o CEP do destinatário: ")
    cidade, estado = consultar_cep(cep)
    if not cidade:
        print("Não foi possível obter os dados do CEP. Encerrando...")
        return None, None

    print(f"Destino: {cidade}, {estado}")
    pacotes = []

    while True:
        dimensoes = input("\nInsira as dimensões do pacote (LxAxP) em cm, separadas por vírgula, ou pressione ENTER para encerrar: ")
        if not dimensoes.strip():  # Encerra se a entrada for vazia
            print("Processo de inserção encerrado. Vamos prosseguir!")
            break
        peso = input("Insira o peso do pacote em kg: ")

        # Adiciona o pacote à lista de pacotes
        pacotes.append({"dimensoes": dimensoes, "peso": peso})

    return pacotes, cidade

# Processa pacotes inseridos pelo usuário
def processamento_logistico(pacotes, destino_cidade):
    print("\nResultados da Simulação Logística:")
    logistica_sao_paulo = {"latitude": -23.550520, "longitude": -46.633308}

    def calcular_distancia(cidade_destino):
        # Simulação de distância - substitua por lógica real
        localidades = {
            "sao paulo": 0,
            "campinas": 100,
            "rio de janeiro": 400,
            "belo horizonte": 600,
            # Adicione mais cidades conforme necessário
        }
        return localidades.get(cidade_destino.lower(), None)

    distancia = calcular_distancia(destino_cidade)
    if distancia is None:
        print("Não foi possível calcular a distância para o destino.")
        return

    custo_total_frete = 0

    for i, dados in enumerate(pacotes):
        try:
            pacote = Pacote(dados["dimensoes"], dados["peso"])
            frete = pacote.calcular_frete(distancia)
            dias = pacote.estimar_dias_entrega(distancia)

            print(f"\nPacote {i+1}:")
            print(f"Dimensões: {dados['dimensoes']} cm")
            print(f"Peso: {dados['peso']} kg")
            print(f"Distância estimada: {distancia:.2f} km")
            print(f"Tipo de transporte sugerido: {pacote.verificar_transporte()}")
            print(f"Custo de frete: R$ {frete:.2f}" if frete else "Custo de frete: Dados inválidos")
            print(f"Tempo estimado para entrega: {dias} dias úteis" if dias else "Tempo estimado: Dados inválidos")

            custo_total_frete += frete if frete else 0
        except Exception as e:
            print(f"Erro ao processar o pacote {i+1}: {e}")

    print(f"\nCusto total do frete: R$ {custo_total_frete:.2f}")

# Executa o programa principal
def main():
    pacotes, destino_cidade = entrada_pacotes()
    if pacotes:
        processamento_logistico(pacotes, destino_cidade)
    else:
        print("\nNenhum pacote foi inserido. Encerrando o programa.")

# Iniciar a simulação
main()
