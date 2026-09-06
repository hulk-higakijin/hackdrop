defmodule HackdropWeb.ErrorHelpers do
  @moduledoc false

  @doc false
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(HackdropWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(HackdropWeb.Gettext, "errors", msg, opts)
    end
  end
end
