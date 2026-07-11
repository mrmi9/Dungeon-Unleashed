extends RefCounted
class_name RunSeedStreams

const POSITIVE_MASK := 0x7fffffff
const INITIAL_MIX := 0x4f1bbcdc
const FNV_PRIME := 16777619


static func derive_seed(run_seed: int, stream_key: String) -> int:
	var value := (int(run_seed) ^ INITIAL_MIX) & POSITIVE_MASK
	for byte in stream_key.to_utf8_buffer():
		value = ((value ^ int(byte)) * FNV_PRIME) & POSITIVE_MASK
	return value if value != 0 else 1
