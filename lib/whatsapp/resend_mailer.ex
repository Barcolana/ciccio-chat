defmodule Whatsapp.ResendMailer do
  @moduledoc """
  Simple Resend email sender using Req
  """

  def send_email(to, subject, text_body) do
    api_key = System.get_env("RESEND_API_KEY")

    body = %{
      from: "Ciccio Chat <onboarding@resend.dev>",
      to: [to],
      subject: subject,
      text: text_body
    }

    Req.post("https://api.resend.com/emails",
      headers: [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ],
      json: body
    )
  end
end
