import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window')
external JSObject get _window;

class RazorpayWebService {
  static void openCheckout({
    required Map<String, dynamic> options,
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String error) onError,
  }) {
    try {
      // Ensure helper function is dynamically injected into window if not present
      if (!_window.hasProperty('openRazorpayWebCheckout'.toJS).toDart) {
        _injectRazorpayHelper();
      }

      final fn = _window.getProperty<JSFunction>('openRazorpayWebCheckout'.toJS);
      final jsonStr = jsonEncode(options);

      fn.callAsFunction(
        _window,
        jsonStr.toJS,
        ((JSString? pId, JSString? oId, JSString? sig) {
          onSuccess(pId?.toDart ?? '', oId?.toDart ?? '', sig?.toDart ?? '');
        }).toJS,
        ((JSString? err) {
          onError(err?.toDart ?? 'Payment failed');
        }).toJS,
      );
    } catch (e) {
      onError('Could not launch Razorpay Web: $e');
    }
  }

  static void _injectRazorpayHelper() {
    const script = '''
      window.openRazorpayWebCheckout = function(optionsJson, successCallback, errorCallback) {
        try {
          var options = typeof optionsJson === 'string' ? JSON.parse(optionsJson) : optionsJson;
          options.handler = function(response) {
            if (successCallback) {
              successCallback(response.razorpay_payment_id || '', response.razorpay_order_id || '', response.razorpay_signature || '');
            }
          };
          options.modal = {
            ondismiss: function() {
              if (errorCallback) {
                errorCallback("Payment cancelled or modal closed");
              }
            }
          };
          if (typeof Razorpay === 'undefined') {
            var s = document.createElement('script');
            s.src = 'https://checkout.razorpay.com/v1/checkout.js';
            s.onload = function() {
              var rzp = new Razorpay(options);
              rzp.on('payment.failed', function(response) {
                if (errorCallback) {
                  var msg = (response && response.error && response.error.description) ? response.error.description : "Payment failed";
                  errorCallback(msg);
                }
              });
              rzp.open();
            };
            document.head.appendChild(s);
            return;
          }
          var rzp = new Razorpay(options);
          rzp.on('payment.failed', function(response) {
            if (errorCallback) {
              var msg = (response && response.error && response.error.description) ? response.error.description : "Payment failed";
              errorCallback(msg);
            }
          });
          rzp.open();
        } catch (err) {
          if (errorCallback) {
            errorCallback("Failed to launch Razorpay Web: " + err);
          }
        }
      };
    ''';
    _window.callMethod('eval'.toJS, script.toJS);
  }
}
