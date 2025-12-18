import React, { useRef, useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { loadBalanceData } from '../redux/slices/balanceSlice'
import { Card, Col, Row, Statistic, Button, Input, Space } from 'antd';

export default function Seft() {
    const dispatch = useDispatch();
    //swapExactTokensForTokens
    const [amountIn, setAmountIn] = useState();
    const [amountOutMin, setAmountOutMin] = useState();
    const [address1, setAddress1] = useState();
    const [address2, setAddress2] = useState();
    const [deadline3, setDeadline3] = useState();

    const toWei = (number) => {
        return number * 10 ** 18;
    }
    return (
        <div>
            <div style={{ marginTop: "10px", padding: "10px" }} ></div>
            <Space.Compact style={{ width: '80%', height: '115px', display: 'flex', margin: '0 auto' }}>
                <Input placeholder="amount In" value={amountIn} style={{ fontSize: '30px' }}
                    onChange={(e) => setAmountIn(e.target.value)} />
                <Input placeholder="amount Out Min" value={amountOutMin} style={{ fontSize: '30px' }}
                    onChange={(e) => setAmountOutMin(e.target.value)} />
                <Input placeholder="address1" value={address1} style={{ fontSize: '30px' }}
                    onChange={(e) => setAddress1(e.target.value)} />
                <Input placeholder="address2" value={address2} style={{ fontSize: '30px' }}
                    onChange={(e) => setAddress2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline3} style={{ fontSize: '30px' }}
                    onChange={(e) => setDeadline3(e.target.value)} />

            </Space.Compact>

            <div style={{ width: '100%', marginTop: '50px', height: '80px' }}>
                <Button type="primary" style={{ width: '40%', height: '80px', display: 'flex', margin: '0 auto', fontSize: '30px' }} onClick={async () => {

                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline3) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    if (address1 === tokenA._address) {
                        await tokenA.methods.approve(router._address, toWei(Number(amountIn))).send({ from: account });
                    } else if (address1 === tokenB._address) {
                        await tokenB.methods.approve(router._address, toWei(Number(amountIn))).send({ from: account });
                    } else {
                        return;
                    }

                    await router.methods.swapExactTokensForTokens(
                        toWei(Number(amountIn)),
                        toWei(Number(amountOutMin)),
                        [address1, address2],
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setAmountIn('');
                    setAmountOutMin('');
                    setAddress1('');
                    setAddress2('');
                    setDeadline3('');
                }}>提交</Button>

            </div>
        </div>
    )
}