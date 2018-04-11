module logic_gates_1(iA, iB, oAnd, oOr, oNot);
    //Structure
    input iA, iB;
    output oAnd, oOr, oNot;
    and gate_and_1 (oAnd, iA, iB);
    or gate_or_1 (oOr, iA, iB);
    not gate_not_1 (oNot, iA);
endmodule