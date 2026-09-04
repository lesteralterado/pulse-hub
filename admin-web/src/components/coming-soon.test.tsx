import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { ComingSoon } from "./coming-soon";

describe("ComingSoon", () => {
  it("renders the given section title", () => {
    render(<ComingSoon title="Users" />);
    expect(screen.getByRole("heading", { name: "Users" })).toBeInTheDocument();
  });
});
