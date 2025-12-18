import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'

//slice 指的是由 createSlice 创建的整个对象：
const balanceSlice = createSlice({
    name: 'balance',

    //定义变量的初始值
    initialState: {
        TokenA: "0", //wei转换需要字符串，不是数字
        TokenB: "0",
        PairTokenA: "0",
        PairTokenB: "0",
        LP:"0"
    },

    //定义变量的修改器 actions
    reducers: {
        setTokenA(state, action) {
            state.TokenA = action.payload;
        },
        setTokenB(state, action) {
            state.TokenB = action.payload;
        },
        setPairTokenA(state, action) {
            state.PairTokenA = action.payload;
        },
        setPairTokenB(state, action) {
            state.PairTokenB = action.payload;
        },
        setLP(state,action){
            state.LP = action.payload
        }
    }
})

//导出修改器 action 供其他组件直接使用这些函数方法
export const { setTokenA, setTokenB, setPairTokenA, setPairTokenB,setLP } = balanceSlice.actions;

//导出 reducer 供 store 使用
export default balanceSlice.reducer;

//这个也是action，不过是异步函数，所以跟上边的set方法不一样
export const loadBalanceData = createAsyncThunk(
    "balance/fetchBalanceData",
    async (data, { dispatch }) => {
        const {
            web3,
            account,
            tokenA,
            tokenB,
            pair,
            factory,
            router
        } = data

        //获取钱包的token
        const TokenAaccount = await tokenA.methods.balanceOf(account).call();
        const TokenBaccount = await tokenB.methods.balanceOf(account).call();
        dispatch(setTokenA(TokenAaccount.toString()))
        dispatch(setTokenB(TokenBaccount.toString()))

        const TokenApair = await tokenA.methods.balanceOf(pair._address).call();
        const TokenBpair = await tokenB.methods.balanceOf(pair._address).call();
        dispatch(setPairTokenA(TokenApair.toString()))
        dispatch(setPairTokenB(TokenBpair.toString()))

        const pairLP = await pair.methods.balanceOf(account).call();
        dispatch(setLP(pairLP.toString()));
    }
)