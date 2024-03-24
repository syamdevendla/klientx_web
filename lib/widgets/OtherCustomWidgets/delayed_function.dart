//*************   © Copyrighted by aagama_it. 

delayedFunction({Function? setstatefn, int? durationmilliseconds}) {
  Future.delayed(Duration(milliseconds: durationmilliseconds ?? 2000), () {
    setstatefn!();
  });
}
