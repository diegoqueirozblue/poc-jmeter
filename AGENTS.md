# Instruções Para Agentes

## Objetivo

Este repositório contém uma POC mínima para medir consultas PostgreSQL com
Apache JMeter. Priorize mudanças pequenas, reproduzíveis e diretamente úteis
para a execução do benchmark.

## Estrutura

- `jmeter/benchmark.jmx`: plano principal do teste.
- `config/`: propriedades locais e exemplo sem credenciais reais.
- `queries/`: consultas SQL carregadas pelo plano.
- `data/`: parâmetros CSV das consultas.
- `scripts/`: entradas recomendadas para execução não gráfica.
- `results/`: arquivos JTL e relatórios gerados, ignorados pelo Git.
- `apache-jmeter/`: instalação vendor do JMeter; não editar nem atualizar como
  parte de uma alteração normal do projeto.

## Regras

- Nunca versionar senhas, URLs com credenciais, resultados ou logs locais.
- Não colocar valores específicos do ambiente no `.jmx`.
- Não modificar o vendor `apache-jmeter/` para corrigir o benchmark.
- Manter consultas e parâmetros fora do `.jmx` sempre que possível.
- Preservar alterações existentes do usuário e não usar comandos destrutivos.
- Não adicionar dashboards, APIs ou coletores de infraestrutura sem requisito
  explícito.

## Execução E Validação

1. Copie `config/benchmark.properties.example` para
   `config/benchmark.properties`.
2. Configure a conexão, a consulta e a carga.
3. Execute `./scripts/run.sh` ou `scripts/run.ps1`.
4. Verifique `results/result.jtl`, o campo `success` e a quantidade de erros.
5. Consulte `results/report/index.html` quando o relatório HTML for gerado.

O código de saída do JMeter não substitui a inspeção das amostras: o processo
pode terminar com código zero mesmo quando existem erros no JTL.

## Resolução Do JMeter

Os scripts devem usar, nesta ordem:

1. `JMETER_BIN` explícito.
2. `JMETER_HOME` explícito.
3. `jmeter` disponível no `PATH`.
4. `apache-jmeter/bin/jmeter` ou `apache-jmeter/bin/jmeter.bat` do repositório.

Ao depurar uma execução, registre qual binário foi selecionado. Confirme que o
driver PostgreSQL está no `lib/` da instalação escolhida.

## Consultas Parametrizadas

Placeholders `?` devem permanecer na consulta SQL. A ordem dos placeholders,
valores CSV e tipos JDBC precisa ser igual. Ao trocar uma consulta, valide
também o schema, as colunas e os tipos existentes no banco.

## Comparações

Para comparar `baseline` e `partitioned`, mantenha a mesma consulta, CSV,
configuração de carga e massa de dados. Faça múltiplas rodadas e trate o
warm-up separadamente antes de interpretar os resultados.

Leia `docs/MAINTENANCE.md` antes de mudanças estruturais no plano ou nos
scripts.
