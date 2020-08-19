defmodule Suomidev.TimeAgo do
  @year_in_seconds 31_536_000
  @month_in_seconds 2_592_000
  @day_in_seconds 86400
  @hour_in_seconds 3600
  @minute_in_seconds 60

  def from_now(naive_datetime) do
    utc_now = NaiveDateTime.utc_now()
    diff = NaiveDateTime.diff(utc_now, naive_datetime)

    cond do
      diff / @year_in_seconds > 1 ->
        "#{format(diff / @year_in_seconds, "year")} sitten"

      diff / @month_in_seconds > 1 ->
        "#{format(diff / @month_in_seconds, "month")} sitten"

      diff / @day_in_seconds > 1 ->
        "#{format(diff / @day_in_seconds, "day")} sitten"

      diff / @hour_in_seconds > 1 ->
        "#{format(diff / @hour_in_seconds, "hour")} sitten"

      diff / @minute_in_seconds > 1 ->
        "#{format(diff / @minute_in_seconds, "minute")} sitten"

      diff / @minute_in_seconds < 1 ->
        "äskettäin"

      true ->
        "joskus"
    end
  end

  def format(interval, term) do
    interval = normalize_interval(interval)

    case term do
      "minute" ->
        if interval > 1, do: "#{interval} minuuttia", else: "minuutti"
      "hour" ->
        if interval > 1, do: "#{interval} tuntia", else: "tunti"
      "day" ->
        if interval > 1, do: "#{interval} päivää", else: "päivä"
      "month" ->
        if interval > 1, do: "#{interval} kuukautta", else: "kuukausi"
      "year" ->
        if interval > 1, do: "#{interval} vuotta", else: "vuosi"
      _ ->
        "joskus"
    end
  end
  def normalize_interval(interval) do
    trunc(Float.floor(interval))
  end
end
