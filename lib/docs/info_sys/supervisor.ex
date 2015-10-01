defmodule Docs.InfoSys.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # http://www.erlang.org/doc/design_principles/sup_princ.html
  # strategies: temporary - die for any reason, no need to restart
  #             permanent - die for any reason, restart (DEFAULT)
  #             transient - die for abnormal reason, restart
  def init(_) do
    children = [
      worker(Docs.InfoSys, [], restart: :temporary)
    ]
    supervise children, strategy: :simple_one_for_one
  end
end
