
## Function for creating weighted averages for piled material decay values

## per_ag is percent above ground, the proportion of a pile that receives the piled coefficient

## per_gc is percent ground contact, the proportion that is considered the same as scattered from decay

## coEf is the piled coefficient value that characterizes a change in decay for suspended materials

## k_const is the k value for that cell

piled_k_const <- function(k_const, coEf = 0.721, per_ag = .892, per_gc = .108) {
  
  k_pile <- ((k_const * coEf) * per_ag) + (k_const * per_gc)
  
  return(k_pile)
}

## example
piled_k_const(.09)
