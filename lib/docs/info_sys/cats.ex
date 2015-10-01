defmodule Docs.InfoSys.Cats do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    send(self, :request)
    # :random.seed(:os.timestamp())
    {:ok, opts}
  end

  def handle_info(:request, opts) do
    if String.contains?(opts[:expr], "cat") do
      img_url = "http://www.cgdev.org/sites/default/files/cat8.jpg"
      send(opts[:client_pid], {:result, self, %{score: 100, img_url: img_url}})
    else
      send(opts[:client_pid], {:noresult, self})
    end
    {:stop, :shutdown, opts}
  end

  defp random_cat() do
    # [
      # "http://www.cgdev.org/sites/default/files/cat8.jpg",
      # "http://i.dailymail.co.uk/i/pix/2014/10/06/1412613364603_wps_17_SANTA_MONICA_CA_AUGUST_04.jpg",
      # "http://breadedcat.com/wp-content/uploads/2012/02/cat-breading-tutorial-004.jpg",
      # "https://www.petfinder.com/wp-content/uploads/2012/11/155293403-cat-adoption-checklist-632x475-e1354290788940.jpg",
      # "http://i.huffpost.com/gen/1860407/images/o-BLACK-FOOTED-CAT-KITTENS-facebook.jpg",
      # "http://i.dailymail.co.uk/i/pix/2014/12/04/23BBF15000000578-0-image-m-28_1417704764841.jpg"
    # ]
    "http://www.cgdev.org/sites/default/files/cat8.jpg"
  end
end
