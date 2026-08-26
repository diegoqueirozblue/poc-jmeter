# Benchmark PostgreSQL com Apache JMeter

POC mínima para medir uma consulta PostgreSQL antes e depois de uma alteração
estrutural, como particionamento de tabela.

## Pré-requisitos

- Apache JMeter 5.6.3 instalado ou a cópia vendor em `apache-jmeter/`.
  Os scripts preferem uma instalação explícita ou disponível no `PATH` e usam
  o vendor como fallback.
- Driver JDBC do PostgreSQL (`postgresql-*.jar`) no diretório `lib/` do JMeter.
- Banco PostgreSQL acessível e com a tabela usada pela consulta de exemplo.

O exemplo atual consulta `public.movimento_estoque` e espera as colunas
`loja_key` e `data_movimento`. Ajuste `queries/consulta_exemplo.sql` e
`data/parametros.csv` se o schema ou os tipos do seu banco forem diferentes.

O plano usa `poolMax=0`, o padrão recomendado para que cada thread mantenha sua
própria conexão. O tempo de abertura da conexão inicial pode aparecer na
primeira amostra; descarte essa amostra ou faça um warm-up separado quando isso
for relevante.

## Configuração

Crie uma cópia do arquivo de exemplo:

```bash
cp config/benchmark.properties.example config/benchmark.properties
```

Edite host, porta, database, usuário e senha. A URL JDBC é montada a partir
desses valores; caso necessário, `db.url` pode sobrescrevê-la. O arquivo é
ignorado pelo Git. Também é possível sobrescrever qualquer propriedade com
`-J`, por exemplo:

```bash
jmeter -n -t jmeter/benchmark.jmx \
  -q config/benchmark.properties \
  -Jthreads=4 -Jiterations=100
```

Para selecionar explicitamente outra instalação:

```bash
JMETER_HOME=/caminho/apache-jmeter ./scripts/run.sh
```

Consulte [AGENTS.md](AGENTS.md) e o [guia de manutenção](docs/MAINTENANCE.md)
para as regras de operação, resolução do JMeter e manutenção do vendor.

A consulta é selecionada por `query.file` e os parâmetros são lidos de
`data.file`. Ambos os caminhos são relativos à raiz do projeto.

## Execução

Linux/macOS:

```bash
./scripts/run.sh
```

Windows PowerShell:

```powershell
.\scripts\run.ps1
```

No PowerShell, o JMeter deve estar no `PATH` ou ser indicado por
`$env:JMETER_BIN`. Para separar os resultados de uma rodada:

```powershell
$env:RESULT_DIR = "results/baseline"
.\scripts\run.ps1
```

Os scripts aceitam o arquivo de propriedades como primeiro argumento:

```bash
./scripts/run.sh config/benchmark.properties
```

Por padrão, os arquivos são gerados em `results/result.jtl` e
`results/report/`. Para preservar rodadas separadas, use variáveis de ambiente
ou PowerShell equivalentes:

```bash
RESULT_DIR=results/baseline ./scripts/run.sh
RESULT_DIR=results/partitioned ./scripts/run.sh
```

O script remove o `.jtl` e o diretório do relatório anteriores dentro do
diretório de saída escolhido.

O relatório HTML é o relatório padrão do JMeter e contém média, mediana,
percentis, throughput, quantidade de amostras, erros, mínimo e máximo.

## Consulta e parâmetros

`queries/consulta_exemplo.sql` usa parâmetros JDBC posicionais (`?`). A ordem
dos placeholders deve corresponder às colunas do CSV e aos tipos configurados
no `JDBC Request` dentro do plano.

Para trocar a consulta, altere `query.file` sem modificar a estrutura do plano.
Para alterar os valores, edite o CSV mantendo a mesma ordem e tipos.

## Carga

As propriedades disponíveis são:

| Propriedade | Padrão | Descrição |
|---|---:|---|
| `threads` | `1` | Threads concorrentes |
| `ramp_up_seconds` | `0` | Tempo de ramp-up |
| `iterations` | `10` | Iterações por thread |
| `scheduler` | `false` | Habilita duração |
| `duration_seconds` | `0` | Duração quando o scheduler está ativo |

Para executar por duração, use por exemplo:

```bash
./scripts/run.sh config/benchmark.properties \
  -Jthreads=4 -Jscheduler=true -Jduration_seconds=300
```

O argumento adicional é repassado diretamente ao JMeter.

O processo pode terminar com código zero mesmo quando amostras individuais
falham. Sempre confira o campo `Err` na saída e a seção de erros do relatório.

## Reprodutibilidade

Para comparar `baseline` e `partitioned`, mantenha a mesma consulta, CSV,
configuração de carga e massa de dados. Faça mais de uma rodada e considere um
warm-up separado antes da coleta oficial. Essa POC não automatiza essas rodadas.
