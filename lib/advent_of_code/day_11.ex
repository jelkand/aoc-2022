defmodule AdventOfCode.Day11 do
  alias AdventOfCode.Day11.Monkey
  alias AdventOfCode.Helpers

  def parse_name(str) do
    str
    |> String.replace(":", "")
    |> String.split(" ")
    |> Enum.map(&String.downcase/1)
    |> Enum.join(":")
  end

  def parse_items(str) do
    Regex.scan(~r"\d+", str) |> List.flatten() |> Enum.map(&Helpers.get_integer/1)
  end

  def parse_op(str) do
    str
    |> String.split("= ")
    |> Enum.at(-1)
    |> String.replace("old", "&1")
    |> (&("&(" <> &1 <> ")")).()
    |> Code.eval_string()
    |> Kernel.elem(0)
  end

  def parse_test(test_str, true_str, false_str) do
    divisor = String.split(test_str, " ") |> Enum.at(-1) |> Helpers.get_integer()
    true_target = String.at(true_str, -1) |> (&("monkey:" <> &1)).()
    false_target = String.at(false_str, -1) |> (&("monkey:" <> &1)).()

    fn val ->
      case rem(val, divisor) == 0 do
        true -> true_target
        false -> false_target
      end
    end
  end

  def parse_monkey([name_str, items_str, op_str, test_str, true_str, false_str]) do
    with name <- parse_name(name_str),
         items <- parse_items(items_str),
         op <- parse_op(op_str),
         test <- parse_test(test_str, true_str, false_str) do
      {name, items, op, test}
    end
  end

  def spawn_monkeys(args) do
    args
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(&parse_monkey/1)
    |> Enum.map(fn {name, _, _, _} = data ->
      {:ok, monkey} = Monkey.start_link(data, name: {:global, name})
      monkey
    end)
  end

  def part1(args) do
    monkeys = spawn_monkeys(args)

    Enum.each(
      1..20,
      fn _ ->
        Enum.each(monkeys, fn monkey ->
          GenServer.call(monkey, {:inspect_items})
        end)
      end
    )

    score_monkeys(monkeys)
  end

  def part2(args) do
    monkeys = spawn_monkeys(args)

    Enum.each(
      1..10000,
      fn _ ->
        Enum.each(monkeys, fn monkey ->
          GenServer.call(monkey, {:inspect_items})
        end)
      end
    )

    score_monkeys(monkeys)
  end

  def score_monkeys(monkeys) do
    Enum.map(monkeys, fn monkey ->
      GenServer.call(monkey, {:get_monkey_business})
    end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(1, &Kernel.*/2)
  end
end

defmodule AdventOfCode.Day11.Monkey do
  use GenServer

  # Client

  def start_link(state, name) do
    GenServer.start_link(__MODULE__, state, name)
  end

  # def inspect_items(pid) do
  #   GenServer.call(pid, {:inspect_items})
  # end

  def get_items(pid) do
    GenServer.call(pid, {:get_items})
  end

  # Server

  @impl true
  def init({name, items, operation, test}) do
    {:ok, {name, items, operation, test, 0}}
  end

  @impl true
  def handle_call({:get_items}, _from, {name, items, _, _, _} = state) do
    {:reply, {name, items}, state}
  end

  @impl true
  def handle_call({:catch_item, element}, _from, {name, items, operation, test, monkey_bsns}) do
    {:reply, :ok, {name, items ++ [element], operation, test, monkey_bsns}}
  end

  @impl true
  def handle_call({:inspect_items}, _, {name, items, operation, test, monkey_bsns}) do
    new_state = inspect_items({name, items, operation, test, monkey_bsns})
    {:reply, Kernel.elem(new_state, 3), new_state}
  end

  @impl true
  def handle_call({:get_monkey_business}, _, {_, _, _, _, monkey_bsns} = state) do
    {:reply, monkey_bsns, state}
  end

  def inspect_items({_, [], _, _, _} = state), do: state

  # iterates through items and returns the new monkey business
  def inspect_items({name, items, operation, test, monkey_bsns}) do
    new_bsns =
      Enum.reduce(items, monkey_bsns, fn item, acc ->
        inspect_item(name, item, operation, test)
        acc + 1
      end)

    {name, [], operation, test, new_bsns}
  end

  def inspect_item(_, item, operation, test) do
    # LCM of the various tests
    # new_item = rem(operation.(item), 96577) # test divisor
    new_item = rem(operation.(item), 9_699_690)
    # |> div(3)
    target = test.(new_item)
    GenServer.call({:global, target}, {:catch_item, new_item})
  end
end
