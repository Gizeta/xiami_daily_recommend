defmodule XiamiDailyRecommend.Decrypto do
  defp index_convert(line, len) do
    ch_per_line = round(Float.ceil(len / line))
    empty_line = rem(len, line)
    fn idx ->
      x = div(idx, line);
      y = rem(idx, line);
      x + y * ch_per_line - if y > empty_line, do: y - empty_line , else: 0
    end
  end

  def decrypt(crypted) do
    << line::utf8 >> <> crypted = crypted
    len = String.length(crypted)
    get_really_index = index_convert(line - 0x30, len)
    (for i <- 0..(len - 1), into: "", do: String.at(crypted, get_really_index.(i)))
    |> URI.decode
    |> String.replace("^", "0")
  end
end
