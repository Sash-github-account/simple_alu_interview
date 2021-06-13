// Stub for a INT8 multiplier

module mul
  (
   input  alu_pkg::uint_t a,
   input  alu_pkg::uint_t b,
   output alu_pkg::uint_t out
   );

  assign out = a * b;
  
endmodule
