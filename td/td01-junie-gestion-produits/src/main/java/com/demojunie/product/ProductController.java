package com.demojunie.product;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import jakarta.validation.Valid;

@Controller
public class ProductController {

    private final ProductRepository repository;

    public ProductController(ProductRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/products")
    public String list(Model model) {
        model.addAttribute("products", repository.findAll());
        return "products";
    }

    @GetMapping("/products/new")
    public String form(Model model) {
        model.addAttribute("product", new Product());
        return "product-form";
    }

    @PostMapping("/products")
    public String create(@Valid @ModelAttribute Product product, BindingResult br) {
        if (br.hasErrors()) return "product-form";
        repository.save(product);
        return "redirect:/products";
    }
}
