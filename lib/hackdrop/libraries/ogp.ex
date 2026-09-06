defmodule Hackdrop.Libraries.Ogp do
  @moduledoc """
  Fetches the Open Graph image URL from a web page.
  """

  @max_body_size 1_000_000
  @request_timeout 5_000
  @meta_tag_regex ~r/<meta\b[^>]*>/i
  @attribute_regex ~r/([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+))/i

  @spec fetch_image_url(String.t()) :: {:ok, String.t()} | :error
  def fetch_image_url(page_url) do
    with {:ok, _uri} <- valid_http_uri(page_url),
         {:ok, %Req.Response{status: 200, body: body}} <- fetch(page_url),
         true <- is_binary(body) and byte_size(body) <= @max_body_size,
         image_url when is_binary(image_url) <- find_image_url(body),
         {:ok, image_url} <- absolute_http_url(page_url, image_url) do
      {:ok, image_url}
    else
      _ -> :error
    end
  end

  defp fetch(url) do
    Req.get(url,
      headers: [{"user-agent", "Hackdrop/1.0"}],
      receive_timeout: @request_timeout,
      connect_options: [timeout: @request_timeout],
      max_redirects: 3
    )
  end

  defp find_image_url(body) do
    @meta_tag_regex
    |> Regex.scan(body)
    |> Enum.find_value(fn [tag] ->
      attributes =
        Regex.scan(@attribute_regex, tag, capture: :all_but_first)
        |> Map.new(fn [name | values] ->
          value = Enum.find(values, &(&1 != ""))
          {String.downcase(name), value}
        end)

      property = attributes["property"] || attributes["name"]

      if property && String.downcase(property) == "og:image" do
        Map.get(attributes, "content")
      end
    end)
    |> case do
      image_url when is_binary(image_url) -> String.trim(image_url)
      _ -> nil
    end
  end

  defp absolute_http_url(page_url, image_url) do
    image_uri = URI.merge(URI.parse(page_url), image_url)

    if image_uri.scheme in ["http", "https"] and is_binary(image_uri.host) do
      {:ok, URI.to_string(image_uri)}
    else
      :error
    end
  end

  defp valid_http_uri(url) do
    uri = URI.parse(url)

    if uri.scheme in ["http", "https"] and is_binary(uri.host) do
      {:ok, uri}
    else
      :error
    end
  end
end
