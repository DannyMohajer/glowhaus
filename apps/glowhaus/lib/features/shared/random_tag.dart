import 'dart:math';

/// A short random tag for client and tab ids, such as `k3x9q1`.
///
/// The bound is below 2^31 on purpose: on the JS build `1 << 32` is 0 (JS
/// shifts are 32-bit), and `nextInt(0)` throws, which once stopped the app
/// from starting on browsers without WasmGC.
String randomTag([Random? random]) =>
    (random ?? Random()).nextInt(0x7fffffff).toRadixString(36);
