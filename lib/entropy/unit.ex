defmodule Entropy.Unit do
  defstruct [number: 1, color: :red]
  @colors [:red, :blue, :green, :yellow, :orange]
  @numbers [1, 2, 3, 4, 5]

  def new do
    %__MODULE__{
      color: get_rnd_color(),
      number: get_rnd_number()
    }
  end

  def change_number(%__MODULE__{} = unit, number) when is_integer(number) do
    %{unit | number: number}
  end

  def change_color(%__MODULE__{} = unit, color) when is_atom(color) do
    %{unit | color: color}
  end

  def get_rnd_color do
    Enum.random(@colors)
  end

  def get_rnd_number do
    Enum.random(@numbers)
  end

  def colors do
    @colors
  end

  def numbers do
    @numbers
  end
end