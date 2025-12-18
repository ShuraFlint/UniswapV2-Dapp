import React, { useRef, useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { loadBalanceData } from '../redux/slices/balanceSlice'
import { Card, Col, Row, Statistic, Button, Input, Space } from 'antd';

export default function Remove() {
    const dispatch = useDispatch();
    //removeliqulity
    const [liquidity, setLiquidity] = useState();
    const [amountAMin2, setamountAMin2] = useState();
    const [amountBMin2, setamountBMin2] = useState();
    const [deadline2, setDeadline2] = useState();

    const toWei = (number) => {
        return number * 10 ** 18;
    }
    return (
        <div>
            <div style={{ marginTop: "10px", padding: "10px" }} ></div>
            <Space.Compact style={{ width: '80%', height: '115px', display: 'flex', margin: '0 auto' }}>
                <Input placeholder="liquidity" value={liquidity} style={{ fontSize: '30px' }}
                    onChange={(e) => setLiquidity(e.target.value)} />
                <Input placeholder="amountA Min" value={amountAMin2} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountAMin2(e.target.value)} />
                <Input placeholder="amountB Min" value={amountBMin2} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountBMin2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline2} style={{ fontSize: '30px' }}
                    onChange={(e) => setDeadline2(e.target.value)} />

            </Space.Compact>
            <div style={{ width: '100%', marginTop: '50px', height: '80px' }}>
                <Button type="primary" style={{ width: '40%', height: '80px', display: 'flex', margin: '0 auto', fontSize: '30px' }} onClick={async () => {
                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline2) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    const bool = await pair.methods.approve(router._address, toWei(Number(liquidity))).send({ from: account });

                    const { amountA, amountB } = await router.methods.removeLiquidity(
                        tokenA._address,
                        tokenB._address,
                        toWei(Number(liquidity)),
                        toWei(Number(amountAMin2)),
                        toWei(Number(amountBMin2)),
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setLiquidity('');
                    setamountAMin2('');
                    setamountBMin2('');
                    setDeadline2('');
                }}>提交</Button>
            </div>
        </div>
    )
}