import bitops

let a = 0b0000_0101'u8

# echo a

template log(a: string) =
  echo "rotateRight: " & a

# proc rotateRight(value: uint8, amount: range[0..8]): uint8 =
#   result = value.rotateRightBits(amount)

#   log "result: " & $result

#   var index = 0

#   log "index: " & $index

#   while result > value:
#     let current = result

#     log "\n\ni: " & $index
#     result.flipBit(index)
#     log "result: " & $result

#     if result > current:
#       log "Flip back"
#       result.flipBit(index)
#     log "result: " & $result

#     inc index


# var b = a.rotateRightBits(1)
# echo b

# var c = a.rotateRight(1)
# echo c


echo 5 shr 1
