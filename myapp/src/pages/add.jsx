import React, { useRef, useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { loadBalanceData } from '../redux/slices/balanceSlice'
import { Card, Col, Row, Statistic, Button, Input, Space } from 'antd';

export default function Add() {
    const dispatch = useDispatch();
    //addliqulity
    const [amountADesired, setamountADesired] = useState();
    const [amountBDesired, setamountBDesired] = useState();
    const [amountAMin, setamountAMin] = useState();
    const [amountBMin, setamountBMin] = useState();
    const [deadline, setDeadline] = useState();

    const toWei = (number) => {
        return number * 10 ** 18;
    }
    return (
        <div>
            <div style={{ marginTop: "10px", padding: "10px" }} ></div>
            <Space.Compact style={{ width: '80%', height: '115px', display: 'flex', margin: '0 auto' }}>
                <Input placeholder="amountA Desired" value={amountADesired} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountADesired(e.target.value)} />
                <Input placeholder="amountB Desired" value={amountBDesired} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountBDesired(e.target.value)} />
                <Input placeholder="amountA Min" value={amountAMin} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountAMin(e.target.value)} />
                <Input placeholder="amountB Min" value={amountBMin} style={{ fontSize: '30px' }}
                    onChange={(e) => setamountBMin(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline} style={{ fontSize: '30px' }}
                    onChange={(e) => setDeadline(e.target.value)} />
            </Space.Compact>
            <div style={{ width: '100%', marginTop: '50px', height: '80px' }}>

                <Button type="primary" style={{ width: '40%', height: '80px', display: 'flex', margin: '0 auto', fontSize: '30px' }} onClick={async () => {
                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    const bool1 = await tokenA.methods.approve(router._address, toWei(Number(amountADesired))).send({ from: account });

                    const bool2 = await tokenB.methods.approve(router._address, toWei(Number(amountBDesired))).send({ from: account });

                    const { amountA, amountB, liquidity } = await router.methods.addLiquidity(
                        tokenA._address,
                        tokenB._address,
                        toWei(Number(amountADesired)),
                        toWei(Number(amountBDesired)),
                        toWei(Number(amountAMin)),
                        toWei(Number(amountBMin)),
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setamountADesired('');
                    setamountBDesired('');
                    setamountAMin('');
                    setamountBMin('');
                    setDeadline('');
                }}>提交</Button>
            </div>

        </div >
    )
}