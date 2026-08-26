# Manutenção E Operação

## Arquitetura

O plano `jmeter/benchmark.jmx` usa um `Thread Group`, uma configuração JDBC,
um `CSV Data Set Config` e um `JDBC Request`. A consulta é carregada de um
arquivo externo com `__FileToString`.

As propriedades são carregadas com `-q config/benchmark.properties` e podem ser
substituídas por `-Jnome=valor`. Os caminhos de `query.file` e `data.file` são
relativos à raiz do projeto, que é usada como diretório de execução pelos
scripts.

## Vendor Do JMeter

`apache-jmeter/` é uma cópia vendorizada do Apache JMeter para permitir a
execução sem instalação global. Ela é um fallback, não parte do benchmark.

Os scripts resolvem o executável nesta ordem:

1. `JMETER_BIN`.
2. `JMETER_HOME`.
3. comando `jmeter` no `PATH`.
4. `apache-jmeter/bin/jmeter` no Linux/macOS ou
   `apache-jmeter/bin/jmeter.bat` no Windows.

Não altere arquivos do vendor durante ajustes no projeto. Se for necessário
atualizá-lo, faça isso em uma mudança isolada e registre a versão utilizada.

O driver JDBC PostgreSQL deve existir no `lib/` do JMeter escolhido. Verifique
a instalação com:

```bash
/caminho/bin/jmeter --version
```

Na prática, prefira:

```bash
JMETER_BIN=/caminho/bin/jmeter ./scripts/run.sh
```

## Configuração

O arquivo `config/benchmark.properties` é local e ignorado pelo Git. Ele deve
ser criado a partir de `config/benchmark.properties.example`.

As propriedades de conexão são `db.host`, `db.port`, `db.name`, `db.user`,
`db.password` e `db.url`. A URL explícita tem precedência sobre a URL montada
com host, porta e database.

As propriedades de carga são `threads`, `ramp_up_seconds`, `iterations`,
`scheduler` e `duration_seconds`.

## Consultas E CSV

O arquivo SQL deve usar `?` para parâmetros posicionais. Os campos do CSV são
associados no `CSV Data Set Config` e enviados ao JDBC Request na mesma ordem.
Os tipos JDBC também ficam no sampler; uma alteração na consulta pode exigir a
alteração desses tipos no `.jmx`.

Evite ponto e vírgula no final da consulta, conforme a configuração do JDBC
Request do JMeter.

## Execução

Execução padrão:

```bash
./scripts/run.sh
```

Execução com configuração e carga sobrescrita:

```bash
./scripts/run.sh config/benchmark.properties \
  -Jthreads=4 -Jiterations=100
```

Os scripts removem o JTL e o relatório anteriores dentro do diretório de
saída. Use `RESULT_DIR` para separar rodadas:

```bash
RESULT_DIR=results/baseline ./scripts/run.sh
RESULT_DIR=results/partitioned ./scripts/run.sh
```

O resultado bruto fica em `result.jtl` e o relatório em `report/`. Verifique
sempre `success`, `responseCode` e `responseMessage`; o código de saída do
JMeter pode ser zero apesar de erros nas amostras.

## Comparação E Reprodutibilidade

Antes de comparar cenários:

- use a mesma consulta e os mesmos parâmetros;
- use a mesma configuração de threads e iterações;
- mantenha a mesma massa de dados;
- registre versão do JMeter, driver, PostgreSQL e configuração de carga;
- execute um warm-up separado quando a abertura de conexão ou cache puder
  influenciar a primeira amostra;
- faça múltiplas rodadas e compare distribuições, não apenas uma média.

Warm-up, múltiplas rodadas e comparação automática ainda não são
automatizados nesta POC.
