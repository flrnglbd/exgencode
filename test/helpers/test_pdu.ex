defmodule Exgencode.TestPdu do
  @moduledoc false
  # This is an internal testing file - it is been build due to protocol consolidation

  require Exgencode
  import Exgencode

  defpdu MsgSubSection, someField: [default: 15, size: 8]

  defpdu PzTestMsg,
    testField: [default: 1, size: 12],
    otherTestField: [size: 24],
    subSection: [default: %MsgSubSection{}, type: :subrecord],
    constField: [default: 10, size: 28, type: :constant]

  defpdu CustomEncodeMsg,
    randomField: [size: 8],
    customField: [
      encode: fn _ -> <<6::size(8)>> end,
      decode: fn pdu, <<_::size(8), rest::bitstring>> ->
        {Map.replace!(pdu, :customField, 6), rest}
      end
    ]

  defpdu VersionedMsg,
    oldField: [default: 10, size: 16],
    newerField: [size: 8, version: ">= 2.0.0"],
    evenNewerField: [
      size: 8,
      version: ">= 2.1.0",
      encode: fn val -> <<val * 2::size(8)>> end,
      decode: fn pdu, <<val::size(8), rest::bitstring>> ->
        {struct(pdu, %{evenNewerField: div(val, 2)}), rest}
      end
    ]

  defpdu EndianMsg,
    bigField: [default: 15, size: 32, endianness: :big],
    smallField: [default: 15, size: 32, endianness: :little]

  defpdu FloatMsg,
    floatField: [size: 32, type: :float],
    littleFloatField: [size: 64, type: :float, endianness: :little]

  defpdu BinaryMsg,
    someHeader: [size: 8, default: 10],
    binaryField: [size: 16, type: :binary]

  defpdu StringMsg,
    someHeader: [size: 8, default: 10],
    stringField: [size: 16, type: :string]

  ### PDUs for doctest

  defpdu CustomPdu,
    normalField: [size: 16, default: 3],
    customField: [
      encode: fn val -> <<val * 2::size(16)>> end,
      decode: fn pdu, <<val::size(16)>> -> {struct(pdu, %{customField: div(val, 2)}), <<>>} end
    ]

  defpdu PduWithConstant, aConstantField: [size: 16, default: 10, type: :constant]

  defpdu SubPdu, someField: [size: 16, default: 1]

  defpdu TopPdu,
    aField: [size: 24],
    subPdu: [type: :subrecord, default: %SubPdu{}]

  defpdu VirtualPdu,
    real_field: [size: 16],
    virtual_field: [type: :virtual]

  defpdu VariablePdu,
    some_field: [size: 16],
    size_field: [size: 16],
    variable_field: [type: :variable, size: :size_field]

  defpdu OtherVariablePdu,
    some_field: [size: 16],
    size_field: [size: 16],
    variable_field: [type: :variable, size: :size_field],
    trailing_field: [size: 8]

  defpdu ConditionalPdu,
    normal_field: [size: 16],
    flag_field: [size: 8],
    conditional_field: [size: 8, conditional: :flag_field],
    another_normal_field: [size: 8],
    second_flag: [size: 8],
    size_field: [size: 16, conditional: :second_flag],
    conditional_variable_field: [type: :variable, size: :size_field, conditional: :second_flag]

  defpdu OffsetPdu,
    offset_to_field_a: [size: 16, offset_to: :field_a],
    offset_to_field_b: [size: 16, offset_to: :field_b],
    offset_to_field_c: [size: 16, offset_to: :field_c],
    field_a: [size: 8],
    size_field: [size: 16],
    variable_field: [type: :variable, size: :size_field],
    field_b: [size: 8],
    field_c: [size: 8, conditional: :offset_to_field_c]

  defpdu SomeSubPdu,
    size_field: [size: 16],
    variable_field: [type: :variable, size: :size_field]

  defpdu OffsetSubPdu,
    offset_to_first_sub: [size: 16, offset_to: :first_sub],
    offset_to_second_sub: [size: 16, offset_to: :second_sub],
    static_field: [size: 8],
    first_sub: [type: :subrecord, default: %SomeSubPdu{}, conditional: :offset_to_first_sub],
    second_sub: [type: :subrecord, default: %SomeSubPdu{}, conditional: :offset_to_first_sub]

  defpdu OffsetSubHeaderPdu,
    header: [type: :header, default: %SomeSubPdu{}],
    offset_to_normal_field: [size: 8, offset_to: :normal_field],
    size_field: [size: 8],
    variable_field: [type: :variable, size: :size_field],
    normal_field: [size: 8]

  defpdu DoubleOffsetPdu,
    first_offset: [size: 8, offset_to: :second_offset],
    second_offset: [size: 8, offset_to: :field_a, conditional: :first_offset],
    field_a: [size: 8, conditional: :second_offset]

  defpdu DoubleOffsetShiftedPdu,
    first_offset: [size: 8, offset_to: :second_offset],
    second_offset: [size: 8, offset_to: :field_a, conditional: :first_offset],
    third_offset: [size: 8, offset_to: :field_b, conditional: :first_offset],
    field_a: [size: 8, conditional: :second_offset],
    field_b: [size: 8, conditional: :third_offset]

  defpdu OffsetWithConditionalFieldPdu,
    offset_1: [size: 8, offset_to: :offset_2],
    offset_2: [size: 8, offset_to: :field_b, conditional: :offset_1],
    field_a: [size: 8, default: 0x00, type: :constant, conditional: :offset_1],
    offset_3: [size: 8, offset_to: :offset_4, conditional: :offset_1],
    field_b: [size: 8, conditional: :offset_2],
    offset_4: [size: 8, default: 0x00, type: :constant, conditional: :offset_3],
    field_d: [size: 8, conditional: :offset_3],
    offset_5: [size: 8, default: 0x00, type: :constant, conditional: :offset_3]

  defpdu VersionedOffsetPdu,
    offset_to_something: [size: 16, offset_to: :something],
    static_field: [size: 8],
    versioned_field: [size: 16, version: ">= 2.0.0"],
    something: [size: 8, conditional: :offset_to_something]

  defpdu SkippedPdu,
    testField: [default: 1, size: 16],
    skippedField: [size: 8, default: 5, type: :skip]

  defpdu CustomSizeFunPdu,
    firstField: [default: 2, size: 8],
    offsetForFun: [offset_to: :oneMore, size: 8],
    custom: [
      encode: fn {size, vals} -> <<size::8, vals::size*8>> end,
      decode: fn pdu, <<size::8, val::binary>> ->
        <<vals::size*8, rest::binary>> = val
        {struct(pdu, %{custom: {size, vals}}), rest}
      end,
      size: fn %CustomSizeFunPdu{custom: {size, _vals}} -> size * 8 end
    ],
    anotherWhyNot: [offset_to: :oneMore, size: 8],
    oneMore: [default: 4, size: 8]

  defpdu OffsetMadnessPdu,
    someField: [default: 3, size: 8],
    offsetToOffset: [offset_to: :anotherOffset, size: 8],
    somethingIrrelevant: [default: 11, size: 16],
    anotherOffset: [offset_to: :somethingElse, size: 8],
    somethingElse: [default: 0, size: 8]
end
