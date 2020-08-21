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
      (interval = diff / @year_in_seconds) > 1 ->
        "#{format(interval, "year")} sitten"

      (interval = diff / @month_in_seconds) > 1 ->
        "#{format(interval, "month")} sitten"

      (interval = diff / @day_in_seconds) > 1 ->
        "#{format(interval, "day")} sitten"

      (interval = diff / @hour_in_seconds) > 1 ->
        "#{format(interval, "hour")} sitten"

      (interval = diff / @minute_in_seconds) > 1 ->
        "#{format(interval, "minute")} sitten"

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
