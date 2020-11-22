package com.myapp;

public class Person {
    private String name;

    public Person(String name) {
        this.name = name;
    }

    public void sayHello() {
        System.out.println("hello my name is " + name);
    }
}