/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, { useState } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  NativeModules,
  Button,
  Toast,
  ActivityIndicator
} from 'react-native';

import {
  Header,
  LearnMoreLinks,
  Colors,
  DebugInstructions,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

const App = () => {

  const [isLoading, setIsLoading] = useState(null)

  const requestHyperPay = (checkoutId) => {

    let data = { checkoutId }
    setTimeout(() => {
      NativeModules.NativeMethod.openHyperPay(data, (response) => {
        console.log(response);
        // get resoucePath
        // Toast.show({
        // text: Identify.__('Payment success !'),
        // type: 'success',
        // duration: 3000,                    
        // });
        console.log(response);
        
        alert('SUCCESS!')
      }, (message) => {
        setTimeout(() => {
          //request cancel
          // Toast.show({
          // text: Identify.__('Sorry, payment failed !'),
          // type: 'danger',
          // duration: 3000,                   
          // });
          alert('Canceled')
        }, 500)
      })
    }, 500);
  }

  const getCheckoutId = async () => {
    try {
      const headers = {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjA2NzQzNTM3LCJqdGkiOiIyYTkyMTczYWZkZDU0NjUwOTc4Y2ZlNmI2NTU0NzJhZiIsInVzZXJfaWQiOjF9.SjEEMJDk2vx3_eO2bkL4lOEzoDhgVIWud5aPNKnZ9GE'}`

      }
      setIsLoading((prevValue) => !prevValue)
      const res = await fetch('https://wejhaat.io/api/tour/get-checkoutid/',
        {
          headers,
          method: 'POST',
          body: JSON.stringify({
            amount: 50,
            currency: 'SAR'
          })
        })
      const result = await res.json()
      console.log(result)
      setIsLoading((prevValue) => !prevValue)
      // alert(result.checkout_id)
      requestHyperPay(result.checkout_id)
    } catch (e) {
      return alert(e)
      setIsLoading((prevValue) => !prevValue)
    }
  }
  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView>
        {
          isLoading
            ? (<ActivityIndicator />)
            : (
              <>
                <Button title="Pay Now" onPress={() => requestHyperPay('DA370B2D367B498ECCED15FC7F86C124.uat01-vm-tx03')} />
                
              </>
            )
        }
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
});

export default App;
