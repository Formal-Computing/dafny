module Alpha {
  function Double(x: int): int { x + x }
  lemma DoubleZero() ensures Double(0) == 0 { }
}

module Beta {
  import A = Alpha
  lemma Check() ensures A.Double(3) == 6 { }
}
