SELECT *
FROM public.movimento_estoque
WHERE loja_key = ?
  AND data_movimento >= ?
  AND data_movimento < ?
