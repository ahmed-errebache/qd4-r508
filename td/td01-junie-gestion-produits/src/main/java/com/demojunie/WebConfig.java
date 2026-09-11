package com.demojunie;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebConfig {

    @GetMapping("/")
    public String root() {
        return "redirect:/products";
    }
}
