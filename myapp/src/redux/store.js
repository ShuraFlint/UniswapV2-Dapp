import { configureStore } from '@reduxjs/toolkit'
import balanceSlice from './slices/balanceSlice'
// import { composeWithDevTools } from 'redux-devtools-extension'

////防止浏览器插件Redux DevTools导致报错的解决方案
const isDevToolsInstalled = typeof window !== 'undefined' &&
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__;

const devToolsConfig = isDevToolsInstalled ? {
    serialize: {
        replacer: (key, value) => {
            if (typeof value === 'bigint') {
                return value.toString() + 'n';
            }
            return value;
        }
    }
} : false;
//createStore被弃用
const store = configureStore({
    reducer: {
        //余额 reducer
        balance: balanceSlice
        //订单 reducer
    },

    //防止浏览器插件Redux DevTools导致报错的解决方案
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            serializableCheck: false,
        }),
    devTools: devToolsConfig

})

export default store