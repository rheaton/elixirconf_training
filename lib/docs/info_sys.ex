defmodule Docs.InfoSys do
  # could eventually support Bing search, Wolfram search, as Docs.InfoSys.Wolfram

  @backends [Docs.InfoSys.Wolfram, Docs.InfoSys.Cats]

  def start_link(backend, opts) do
    backend.start_link(opts)
  end


  # Task is for parallelizable work (simple task/cheap concurrency, e.g. ecto query)
  def compute_img(expr) do
    @backends
    |> Enum.map(fn backend ->
      Task.Supervisor.async(Docs.TaskSupervisor,
      backend, :compute_img, [[client_pid: self, expr: expr]])
    end)
    |> Enum.map(&Task.yield(&1, 5000))
    |> Stream.filter(fn
      {:ok, :noresult} -> false
      {:ok, _} -> true
      _ -> false
    end)
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.sort_by(fn result -> result.score end, &>/2)
  end
end

