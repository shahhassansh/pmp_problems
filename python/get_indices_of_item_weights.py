from typing import List

def get_indices_of_item_weights(arr: List[int], limit: int) -> List[int]:
    dct = {}
    for i in range(len(arr)):
        if (limit - arr[i]) in dct:
            return [i, dct[limit - arr[i]]]
        else:
            dct[arr[i]] = i 
 
    return []
