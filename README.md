# Exstreme

Exstreme is an implementation of a Stream Push data structure in the way of a runnable graph where all the nodes must be connected and process a message and pass the result to next node(s)

## Installation

The package can be installed as:

  1. Add exstreme to your list of dependencies in `mix.exs`:

        def deps do
          [{:exstreme, "~> 0.0.2"}]
        end

  2. Check the documentation: [available in Hex](https://hexdocs.pm/exstreme/doc/Exstreme.html)

## Usage

A graph is a data structure that contains nodes connected between them, this graphs must start with only one node and can finish in many nodes, all the nodes in the graph must be connected, for example:

```
              n3
            |
n1 - n2 - b1
            |
              n4
```

The information of a graph is:

* `:name` - Name assigned for the graph, if you don't assign a name this will be generated
* `:nodes` - The nodes with their parameters as a keyword list
* `:connections` - The nodes and their connections

The nodes can be of three types:

* `Common` - it represents a node that is connected to can be connected to another node and can receive a message from another node, represented by the n letter.

* `Broadcast` - it is a node that can broadcast a message to multiple nodes, represented by the b letter.

* `Funnel` - it receives messages from a group of nodes and sends it to the next, represented by the f letter.

A graph could look like this:

```
              n3
            |    |
n1 - n2 - b1       f1 - n5
            |    |
              n4
```

It works this way:

- **n1** passes the message to **n2**
- **n2** passes the message to **b1**
- **b1** broadcasts the message to **n3** and **n4**
- **f1** receives the message from **n3** and **n4** and packages them as one and sends that to **n5**
- **n5** process the message received from **f1**

How to create a graph:

```elixir
    graph = GraphCreator.create_graph("name")
    {graph, n1} = GraphCreator.create_node(graph, params)
    {graph, n2} = GraphCreator.create_node(graph, params)
    GraphCreator.add_connection(graph, n1, n2)
```

A complex one(this is the one for graph above):

```elixir
    graph = GraphCreator.create_graph("name")
    {graph, n1} = GraphCreator.create_node(graph, params)
    {graph, n2} = GraphCreator.create_node(graph, params)
    {graph, b1} = GraphCreator.create_broadcast(graph, params_broadcast)
    {graph, n3} = GraphCreator.create_node(graph, params)
    {graph, n4} = GraphCreator.create_node(graph, params)
    {graph, f1} = GraphCreator.create_funnel(graph, params_funnel)
    {graph, n5} = GraphCreator.create_node(graph, params)

    graph
      |> GraphCreator.add_connection(n1, n2)
      |> GraphCreator.add_connection(n2, b1)
      |> GraphCreator.add_connection(b1, n3)
      |> GraphCreator.add_connection(b1, n4)
      |> GraphCreator.add_connection(n3, f1)
      |> GraphCreator.add_connection(n4, f1)
      |> GraphCreator.add_connection(f1, n5)
  ```

The nodes in the graph are named like this if the name of the graph is "demo":

* `n1` - :n_demo_1
* `n2` - :n_demo_2
* `b1` - :b_demo_1
* `f1` - :f_demo_1

The node params must have a function that is the one called every time a message arrives to the node. The function receives  a tuple where the first parameter is the message and the second one the node data, it must return a tuple with :ok and the new message.

```elixir
    params = [func: fn({msg, node_data}) -> {:ok, new_msg} end]
```

We build a graph after we create it, like this:

```elixir
    graph_built = GraphBuilder.build(graph)
```

The name of the supervisor is the name of the graph so you can get the pid for the supervisor:

```elixir
    pid =
      graph_built.name
      |> String.to_atom
      |> Process.whereis
```

Also we can get the pid for the nodes:

```elixir
    Enum.each(graph_built.nodes, fn({nid, params}) ->
      pid = Process.whereis(nid)
    end)
```

And we can connect a process to the graph and receive the output of the processing:

```elixir
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    :ok = GenServer.call(last_node, {:connect, self})
    GenServer.cast(start_node, {:next, self, {:sum, 0}})
```

If I try to build another graph with the same I'll get an error because there can't be two process with the same name.
