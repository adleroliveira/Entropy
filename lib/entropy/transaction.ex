defmodule Entropy.Transaction do
  defstruct [
    :type,
    :amount,
    :timestamp,
    :description,
    investment: false,
    return: false
  ]

  def amend(type, amount, description \\ "amend") when is_atom(type) do
    %__MODULE__{
      type: type,
      amount: amount,
      timestamp: :os.system_time(:seconds),
      description: description
    }
  end

  def credit(amount, description \\ "credit") do
    %__MODULE__{
      type: :credit,
      amount: amount,
      timestamp: :os.system_time(:seconds),
      description: description,
      return: true
    }
  end

  def debit(amount, description \\ "debit") do
    %__MODULE__{
      type: :debit,
      amount: amount,
      timestamp: :os.system_time(:seconds),
      description: description,
      investment: true
    }
  end
end