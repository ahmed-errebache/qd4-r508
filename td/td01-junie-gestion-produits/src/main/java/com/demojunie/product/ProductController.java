package com.demojunie.product;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.validation.Valid;
import java.util.List;

@Controller
public class ProductController {

    private final ProductRepository repository;

    public ProductController(ProductRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/products")
    public String list(@RequestParam(name = "q", required = false) String q, Model model) {
        List<Product> products;
        if (q != null && !q.isBlank()) {
            products = repository.findByNameContainingIgnoreCase(q.trim());
        } else {
            products = repository.findAll();
        }
        model.addAttribute("products", products);
        model.addAttribute("q", q == null ? "" : q);
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

    @GetMapping("/products/{id}/edit")
    public String edit(@PathVariable Long id, Model model) {
        Product p = repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Invalid id"));
        model.addAttribute("product", p);
        return "product-form";
    }

    @PostMapping("/products/{id}")
    public String update(@PathVariable Long id, @Valid @ModelAttribute Product product, BindingResult br) {
        if (br.hasErrors()) return "product-form";
        product.setId(id);
        repository.save(product);
        return "redirect:/products";
    }

    @PostMapping("/products/{id}/delete")
    public String delete(@PathVariable Long id) {
        repository.deleteById(id);
        return "redirect:/products";
    }
}
