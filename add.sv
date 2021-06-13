// Stub for a INT8 adder

module add
  (
   input  alu_pkg::uint_t a,
   input  alu_pkg::uint_t b,
   output alu_pkg::uint_t out
   );

  assign out = a + b;
  
endmodule
