extends Node
class_name Promise
# Partial implementation of JS "Promise" in GDScript. Missing "then/catch/finally".
# Used to collect several signals into a single await call.

var sigs_good = []
var sigs_bad = []
var now_listing_good_sigs = true;
var is_settled = false;
signal settled;

const DefaultResult = {"settled":false, "success":false, "signal":null, "data":null}
var result = DefaultResult.duplicate();
# example usage: result = await Promise.new(sig_good)._or(sig_good2)._else(sig_bad)._or(sig_bad2)._wait()

func make_sig_handler(sig, is_good, n_vars):
	# GDScript does not have **kwargs :(
		match n_vars:
			0: return func(): got_signal(sig, is_good, null);
			1: return func(value): got_signal(sig, is_good, value);
			2: return func(val1, val2): got_signal(sig, is_good, [val1, val2]);
			3: return func(val1, val2, val3): got_signal(sig, is_good, [val1, val2, val3]);

func _init(sig:Signal, n_vars=1) -> void:
	sig.connect(make_sig_handler(sig, true, n_vars))
	sigs_good.append(sig);

func _or(sig:Signal, n_vars=1):
	sig.connect(make_sig_handler(sig, now_listing_good_sigs, n_vars))
	if now_listing_good_sigs:	sigs_good.append(sig);
	else:						sigs_bad.append(sig);
	return self;

func _else(sig:Signal, n_vars=1):
	now_listing_good_sigs = false;
	sig.connect(make_sig_handler(sig, now_listing_good_sigs, n_vars));
	sigs_bad.append(sig);
	return self;

func wait():
	if is_settled: return result;
	var res = await settled;
	return res;

func got_signal(sig, is_good, val):
	result.settled = true;
	result.success = is_good;
	result.signal = sig;
	result.data = val;
	settled.emit(result);
