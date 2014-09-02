fs = File.stream!("./draft.csv")

IO.inspect {"P", {"Urg", "Rnd Urg", "Exp round", "Exp round 2", "Exp round 10"}}
fs
  |> Enum.map(fn(line) ->
    String.strip(line) |> String.split ","
  end) |> Enum.with_index |> Enum.group_by(fn({[_, _, pos, _], _}) ->
    pos
  end) |> Enum.map(fn({key, coll}) ->
    {key, Enum.map(coll, fn({[rank, name | _], i}) ->
      {elem(Float.parse(rank), 0), name, i}
    end) |> Enum.sort_by &elem(&1, 0)}
  end) |> Enum.map(fn({key, coll}) ->
    urgency = Enum.chunk(coll, 2, 1) |> Enum.take_every(10)
    [[{first, name, i}, {second, _, j}], [{later,_,k} | _] | _] = urgency
    {key, {Float.round(second - first, 2), Float.round(later - first, 2), i/10, j/10, k/10, name}}
  end) |> Enum.sort(fn(p1, p2) ->
    {_, {sing_u, rnd_u, exp, _exp2, _exp10, _}} = p1
    {_, {asing_u, arnd_u, aexp, _aexp2, _aexp10, _}} = p2
    exp = trunc(exp)
    aexp = trunc(aexp)
    cond do
      exp == aexp -> cond do
          trunc(sing_u/5) == trunc(asing_u/5) -> rnd_u > arnd_u
          true -> trunc(sing_u/5) > trunc(asing_u/5)
        end
      true -> exp < aexp
    end
  end) |> Enum.each &IO.inspect/1
